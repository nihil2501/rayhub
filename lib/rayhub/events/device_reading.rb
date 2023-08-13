# frozen_string_literal: true

module Rayhub
  module Events
    DeviceReading =
      Data.define(
        :device_id,
        # For now, the `reading_type` information is already captured by the
        # class itself.
        # :reading_type,
        :quantity,
        :unit,
        :taken_at,
      )

    class DeviceReading
      class << self
        def create(**attrs)
          attrs = {
            unit: self::UNIT,
            **attrs,
          }

          new(**attrs).tap do |event|
            # TODO: document our interesting thinking here.
            EventSourcing.on_event_loaded(event)
          end
        end
      end

      class Count < self
        UNIT = :each
      end
    end
  end
end
