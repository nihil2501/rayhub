# frozen_string_literal: true

module Rayhub
  class Routes < Hanami::Routes
    post(
      "/device_reading_batches",
      to: "device_reading_batches.create"
    )

    get(
      "/device_reading_summaries/:device_id",
      to: "device_reading_summaries.show"
    )
  end
end
