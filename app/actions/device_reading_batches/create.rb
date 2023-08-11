# frozen_string_literal: true

module Rayhub
  module Actions
    module DeviceReadingBatches
      class Create < Rayhub::Action
        # We might want to persist the input to this action and return from it
        # as quickly as possible.
        #
        # In the extreme case, we could choose not to perform parameter
        # validation here at all and instead only notice and inform about
        # violations out-of-band. In this approach, we'd want to think about
        # whether invalidity is even a realistic runtime possibility for a
        # device that was previously working fine. If it somehow is, maybe
        # upstream clients have some way to persist their output so that
        # replayability is an option.
        #
        # If we want to validate synchronously, then there might be a speed-up
        # that performs the mapping and persistence of a domain object in
        # combination with the validation of each element of `readings`.
        #
        # Here, I've opted to perform validation and then separately map and
        # persist the entire `DeviceReadingBatch`. In particular the `id` and
        # `timestamp` keys in the API spec are not ideal names. So my approach
        # is to kind of simulate that they were named ideally by performing
        # some extra iteration that doesn't accomplish much other than renaming.
        params do
          required(:id).filled(:string)
          required(:readings).array(:hash) do
            required(:timestamp).filled(:date_time)
            required(:count).filled(:integer)
          end
        end

        def handle(request, response)
          if request.params.valid?
            device =
              Models::DeviceReadingBatch::Device.new(
                id: request.params[:id]
              )

            reading_batch =
              request.params[:readings].map do |reading|
                Models::DeviceReadingBatch::ReadingBatch.new(
                  taken_at: reading[:timestamp],
                  count: reading[:count]
                )
              end

            batch =
              Models::DeviceReadingBatch.new(
                device:,
                reading_batch:
              )

            Models::DeviceReadingBatch::Store << batch

            response.status = :created
          else
            response.body = request.params.errors.to_json
            response.status = :unprocessable_entity
          end
        end
      end
    end
  end
end
