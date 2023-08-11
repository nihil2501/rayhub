# frozen_string_literal: true

module Rayhub
  module Events
    DeviceReading =
      Data.define(
        :device_id,
        :taken_at,
        :count,
      )

    class DeviceReading
      class Queue
        class << self
          def [](device_id)
            @device_queues ||= Hash.new { |h, k| h[k] = new }
            @device_queues[device_id]
          end
        end

        def initialize
          @events = []
        end

        def enqueue(event)
          @events.push(event)
        end

        def dequeue
          @events.shift
        end
      end
    end
  end
end
