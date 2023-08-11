# frozen_string_literal: true

module Rayhub
  module Models
    DeviceReadingBatch = Data.define(:device, :reading_batch)
    DeviceReadingBatch::Device = Data.define(:id)
    DeviceReadingBatch::ReadingBatch = Data.define(:taken_at, :count)

    class DeviceReadingBatch
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
