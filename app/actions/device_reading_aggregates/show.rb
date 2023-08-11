# frozen_string_literal: true

module Rayhub
  module Actions
    module DeviceReadingAggregates
      class Show < Rayhub::Action
        params do
          required(:device_id).filled(:string)
          optional(:statistics).array(:string)
          optional(:as_of).value(:date_time)
        end

        def handle(*, response)
          response.body = self.class.name
        end
      end
    end
  end
end
