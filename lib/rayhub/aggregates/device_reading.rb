# frozen_string_literal: true

module Rayhub
  module Aggregates
    class DeviceReading
      class << self
        def find(device_id)
          id = :"#{self}/#{device_id}"
          @repository ||= Hash.new { |h, k| h[k] = new(k) }

          @repository[id].tap do |aggregate|
            # TODO: document our interesting thinking here.
            EventSourcing.on_aggregate_loaded(aggregate)
          end
        end
      end

      attr_reader :device_id

      def initialize(device_id)
        @device_id = device_id
      end

      private

      def redundant?(event)
        @taken_ats ||= Set[]
        !@taken_ats.add?(event.taken_at)
      end

      class Count < self
        attr_reader \
          :max_taken_at,
          :quantity_sum,

        # TODO: Define this generically in parent class as a function that
        # applies the event in topological order to a declaratively defined DAG
        # of dependent attributes.
        def apply(event)
          return if redundant?(event)

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
