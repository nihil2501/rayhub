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
      class << self
        def create(**attrs)
          @queues ||= Hash.new { |h, k| h[k] = [] }
          queue = @queues[attrs[:device_id]]
          event = new(**attrs)
          queue << event
        end
      end
    end
  end
end
