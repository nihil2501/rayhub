# frozen_string_literal: true

require "event_sourcing"

module Rayhub
  module Aggregates
    class DeviceReading
      Error = Class.new(RuntimeError)
      NotFoundError = Class.new(Error)

      class << self
        def find(device_id)
          repository[device_id].tap do |aggregate|
            # Because we don't have another process that is dedicated to
            # carrying out event-sourcing asynchronously, we simulate that we do
            # by producing the result of the processing half of the process and
            # immediately advance the event-sourcing state to the point where a
            # an aggregate has had all relevant events applied to it (under the
            # hood this means that a corresponding work queue of some kind is
            # drained and each item applied to the aggregate). By simulating
            # this here, rather than up a layer, we let the caller just call
            # `find` as if it were a genuine event-sourcing system.
            EventSourcing.on_aggregate_loaded(aggregate)
            next if aggregate.persisted?

            # Limit the trash that would be created by clients that fetch
            # nonexistent aggregates from the API.
            repository.delete(aggregate.device_id)
            raise NotFoundError
          end
        end

        def nuke!
          @repository = nil
        end

        private

        def repository
          @repository ||=
            Hash.new do |memo, device_id|
              memo[device_id] = new(device_id)
            end
        end
      end

      attr_reader :device_id

      def initialize(device_id)
        @device_id = device_id
        @taken_ats = Set[]
      end

      def apply(event)
        return if redundant?(event)
        update(event)
      end

      def persisted?
        !@taken_ats.empty?
      end

      private

      def redundant?(event)
        !@taken_ats.add?(event.taken_at)
      end

      class Count < self
        attr_reader(
          :max_taken_at,
          :quantity_sum,
        )

        private

        # TODO: Define this generically in parent class as a function that
        # applies the event in topological order to a declaratively defined DAG
        # of dependent attributes.
        def update(event)
          @max_taken_at = [
            @max_taken_at,
            event.taken_at
          ].compact.max

          @quantity_sum = (
            @quantity_sum.to_i +
            event.quantity
          )
        end
      end
    end
  end
end
