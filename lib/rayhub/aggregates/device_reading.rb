# frozen_string_literal: true

require "event_sourcing"

module Rayhub
  module Aggregates
    class DeviceReading
      Error = Class.new(RuntimeError)
      NotFound = Class.new(Error)

      class << self
        def find(device_id)
          id = :"#{self}/#{device_id}"
          @repository ||=
            Hash.new do |memo, id|
              memo[id] = new(id)
            end

          @repository[id].tap do |aggregate|
            # TODO: Document our interesting thinking here.
            EventSourcing.on_aggregate_loaded(aggregate)
            ensure_found!(aggregate)
          end
        end

        private

        # TODO: Describe simulate-hood of this.
        def ensure_found!(aggregate)
          return if found?(aggregate)
          @repository.delete(aggregate.id)
          raise NotFound
        end

        def found?(aggregate)
          !aggregate
            .instance_variable_get(:@taken_ats)
            .empty?
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
