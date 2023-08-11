# frozen_string_literal: true

module Rayhub
  class Routes < Hanami::Routes
    post(
      "/device_reading_event_batches",
      to: "device_reading_event_batches.create"
    )
  end
end
