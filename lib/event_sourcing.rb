# frozen_string_literal: true

module EventSourcing
  class << self
    def on_event_loaded(event)
      case event
      when Rayhub::Events::DeviceReading::Count
        topic = :"device-reading/#{event.device_id}/count"
        queue = topic_queues[topic]
        queue << event
      end
    end

    def on_aggregate_loaded(aggregate)
      case aggregate
      when Rayhub::Aggregates::DeviceReading::Count
        topic = :"device-reading/#{aggregate.device_id}/count"
        queue = topic_queues[topic]

        while event = queue.shift do
          aggregate.apply(event)
        end
      end
    end

    private

    def topic_queues
      @topic_queues ||= Hash.new { |h, k| h[k] = new }
    end
  end
end
