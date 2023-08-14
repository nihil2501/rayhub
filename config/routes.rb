# frozen_string_literal: true

module Rayhub
  class Routes < Hanami::Routes
    scope "device_readings" do
      post "/", to: "device_readings.create"
      get "/summary", to: "device_readings.summary"
    end
  end
end
