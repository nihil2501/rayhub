# frozen_string_literal: true

require "hanami"

module Rayhub
  class App < Hanami::App
    config.actions.format :json
  end
end
