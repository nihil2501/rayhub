# frozen_string_literal: true

module EventSourcing
  class << self
    def on_event_loaded(event)
      case event
      when Rayhub::Events::DeviceReading::Count
        device_id = event.device_id
        topic = Topics::COUNT_DEVICE_READING % { device_id: }
        queue = topic_queues[topic.to_sym]
        queue << event
      end
    end

    def on_aggregate_loaded(aggregate)
      case aggregate
      when Rayhub::Aggregates::DeviceReading::Count
        device_id = aggregate.device_id
        topic = Topics::COUNT_DEVICE_READING % { device_id: }
        queue = topic_queues[topic.to_sym]

        while event = queue.shift do
          aggregate.apply(event)
        end
      end
    end

    private

    def topic_queues
      @topic_queues ||= Hash.new { |h, k| h[k] = [] }
    end
  end

  module Topics
    ALL = [
      COUNT_DEVICE_READING =
        "device-reading/%{device_id}/count",
    ].freeze
  end
end
