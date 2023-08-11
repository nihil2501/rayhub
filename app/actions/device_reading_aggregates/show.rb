# frozen_string_literal: true

module Rayhub
  module Actions
    module DeviceReadingAggregates
      class Show < Rayhub::Action
        def handle(*, response)
          response.body = self.class.name
        end
      end
    end
  end
end
