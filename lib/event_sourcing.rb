# frozen_string_literal: true

module EventSourcing
  class << self
    def on_event_loaded(event)
      case event
      when Rayhub::Events::DeviceReading::Count
        topic = :"device_reading/#{event.device_id}/count"
        TopicQueue.enqueue(topic, event)
      end
    end

    def on_aggregate_loaded(aggregate)
      case aggregate
      when Rayhub::Aggregates::DeviceReading::Count
        topic = :"device_reading/#{aggregate.device_id}/count"
        TopicQueue.drain(topic) do |event|
          aggregate.apply(event)
        end
      end
    end
  end

  module TopicQueue
    class << self
      def enqueue(*topic, item)
        queue = topic_queues[topic]
        queue << item
      end

      def drain(*topic, &process)
        queue = topic_queues.delete(topic)
        while item = queue.shift do
          process&.(item)
        end
      end

      private

      def topic_queues
        @topic_queues ||=
          Hash.new do |memo, topic|
            memo[topic] = []
          end
      end
    end
  end
end
