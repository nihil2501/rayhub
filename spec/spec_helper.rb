# frozen_string_literal: true

require "pathname"
SPEC_ROOT = Pathname(__dir__).realpath.freeze

ENV["HANAMI_ENV"] ||= "test"
require "hanami/prepare"

require_relative "support/rspec"
require_relative "support/requests"

require "event_sourcing"

RSpec.configure do |config|
  config.before(:example) do
    EventSourcing::TopicQueue.nuke!
  end
end
