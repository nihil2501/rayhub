# frozen_string_literal: true

module EventSourcing
  # TODO: Here we hardcoded domain-specific logic into our generic event
  # sourcing module. Ideally, this module exposes a way to register
  # configurations that some other domain-specific code location will leverage.
  # The configuration should allow one to specify 4 parameters such that an
  # event will be associated through a topic to the appropiate aggregate.
  # The configuration parameters are something like:
  #   * event_type
  #   * get_id_from_event
  #   * aggregate_type
  #   * get_id_from_aggregate
  # These parameters would be packaged together under a particular topic family,
  # and then a topic will be the pairing of this family with an entity id.
  class << self
    def on_event_loaded(event)
      topic =
        case event
        when Rayhub::Events::DeviceReading::Count
          :"device_reading/#{event.device_id}/count"
        end

      TopicQueue.enqueue(
        topic,
        event
      )
    end

    def on_aggregate_loaded(aggregate)
      topic =
        case aggregate
        when Rayhub::Aggregates::DeviceReading::Count
          :"device_reading/#{aggregate.device_id}/count"
        end

      TopicQueue.drain(topic) do |event|
        aggregate.apply(event)
      end
    end
  end

  # `TopicQueue`, which is per-device-per-attribute, is isolated as just a
  # possible implementation of carrying out the event sourcing.
  module TopicQueue
    class << self
      def enqueue(topic, item)
        queue = topic_queues[topic]
        queue << item
      end

      def drain(topic, &process)
        # Notice that we delete the topic queue when draining. In particular,
        # this helps limit trash that would be created by clients that fetch
        # nonexistent aggregates from the API.
        queue = topic_queues.delete(topic).to_a
        while item = queue.shift do
          process&.(item)
        end
      end

      def nuke!
        @topic_queues = nil
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
