# frozen_string_literal: true

module Rayhub
  class Routes < Hanami::Routes
    post(
      "/device_readings",
      to: "device_readings.create"
    )

    get(
      "/device_readings/summary",
      to: "device_readings.summary"
    )
  end
end
