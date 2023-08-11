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
      module Store
        class << self
          include Enumerable
          extend Forwardable

          def_delegators :records, :<<, :each

          def records
            @records ||= []
          end
        end
      end
    end
  end
end
