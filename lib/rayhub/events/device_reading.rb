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
            # Because we don't have another process that is dedicated to
            # carrying out event-sourcing asynchronously, we simulate that we do
            # by producing the result of the ingestion half of the process and
            # immediately advance the event-sourcing state to the point where a
            # persisted event is loaded into the system (under the hood this
            # means that it is placed into a work queue of some kind). By
            # simulating this here, rather than up a layer, we let the caller
            # just call `create` as if it were a genuine event-sourcing system. 
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
