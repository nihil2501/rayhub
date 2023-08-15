# frozen_string_literal: true

require "event_sourcing"

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

      # Might be nice to find a different way to achieve polymorphism because
      # template pattern means there is subclass only code that is invoked from
      # superclass--confusing!
      class Count < self
        UNIT = :each
      end
    end
  end
end
