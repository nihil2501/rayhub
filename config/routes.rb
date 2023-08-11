# frozen_string_literal: true

module Rayhub
  class Routes < Hanami::Routes
    post(
      "/device_reading_events",
      to: "device_reading_events.create"
    )

    get(
      "/device_reading_aggregates/:device_id",
      to: "device_reading_aggregates.show"
    )
  end
end
