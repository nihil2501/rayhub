# frozen_string_literal: true

module EventSourcing
  class << self
    def on_event_loaded(event)
      case event
      when Rayhub::Events::DeviceReading::Count
        queue = TopicQueue.count_device_reading(event.device_id)
        queue.enqueue(event)
      end
    end

    def on_aggregate_loaded(aggregate)
      case aggregate
      when Rayhub::Aggregates::DeviceReading::Count
        queue = TopicQueue.count_device_reading(aggregate.device_id)
        queue.drain { |event| aggregate.apply(event) }
      end
    end
  end

  class TopicQueue
    TOPICS = [
      :count_device_reading,
    ].freeze

    TOPICS.each do |topic|
      define_method(topic) do |*args|
        topic = :"#{topic}(#{args})"
        @topic_queues ||=
          Hash.new do |memo, topic|
            memo[topic] = new
          end

        @topic_queues[topic]
      end
    end

    def initialize
      @queue = []
    end

    def enqueue(item)
      @queue << item
    end

    def dequeue
      @queue.shift
    end

    def drain
      yield(dequeue) until empty?
    end
  end
end
