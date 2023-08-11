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
      module Queue
        class << self
          def enqueue(event)
            events.push(event)
          end

          def dequeue
            events.shift
          end

          private

          def events
            @events ||= []
          end
        end
      end
    end
  end
end
