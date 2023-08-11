# auto_register: false
# frozen_string_literal: true

require "hanami/action"

module Rayhub
  class Action < Hanami::Action
    before do |request|
      next if request.params.valid?

      body = { errors: request.params.errors }.to_json
      halt :unprocessable_entity, body
    end
  end
end
