# frozen_string_literal: true

module Rayhub
  module Actions
    module DeviceReadingEvents
      # We might want to persist the input to this action and return from it
      # as quickly as possible. There are three distinct operations that will
      # impact the cost of the work performed by this endpoint depending on
      # which of the operations we choose to perform. They are:
      #   1. Request parameter validation
      #   2. Domain model mapping
      #   3. Data processing
      #
      # Data processing:
      # Here we choose a design that foregoes the data processing step and
      # instead decouples that activity from the work of this endpoint. This
      # endpoint will be concerned with the network and persistence work. The
      # data processing work can happen out-of-band from this request on an
      # ongoing basis in the background in addition to on an on-demand basis
      # when we service requests to the counterpart summary statistics
      # endpoint. In particular, the out-of-band processing can contribute to
      # the work needed to provide the answers demanded by the summary
      # statistics endpoint.
      #
      # Request parameter validation:
      # In the cheapest approach, we could choose not to perform parameter
      # validation here at all and instead, only notice and inform about
      # violations out-of-band. In this approach, we'd want to consider
      # whether invalidity is even a realistic runtime possibility for a
      # device that was heretofore POSTing correctly. If it somehow is, maybe
      # upstream clients can be designed to persist their data locally so that
      # replayability is an option for fault tolerance. The idempotency of the
      # model associated with this endpoint already lends itself to such a
      # design.
      #
      # Domain model mapping:
      # If we do want to validate synchronously so that we can inform the
      # caller of client of errors, next we can consider whether to take more
      # time and map the data to a model that is more appropriate than the
      # request parameter shape for the internal implementation of our domain.
      # There might however be a speed-up where the mapping and persistence of
      # the domain model are actually performed during the validation step.
      #
      # Here, we perform request parameter validation and then domain model
      # mapping in two separate steps and then forego any further data
      # processing. We could probably choose an API object shape that matches
      # the domain model.
      class Create < Rayhub::Action
        before :validate_params

        params do
          required(:id).filled(:string)
          required(:readings).array(:hash) do
            required(:timestamp).filled(:date_time)
            required(:count).filled(:integer)
          end
        end

        def handle(request, response)
          device_id = request.params[:id]
          readings = request.params[:readings]

          readings.each do |reading|
            taken_at = reading[:timestamp]
            count = reading[:count]

            Events::DeviceReading::Queue.enqueue(
              Events::DeviceReading.new(
                device_id:,
                taken_at:,
                count:,
              )
            )
          end

          response.status = :created
          response.body = ""
        end

        private

        def validate_params(request, *)
          return if request.params.valid?

          body = { errors: request.params.errors }.to_json
          halt :unprocessable_entity, body
        end
      end
    end
  end
end
