# frozen_string_literal: true

module Rayhub
  class Routes < Hanami::Routes
    post "/device_reading_batches", to: "device_reading_batches.create"
  end
end
