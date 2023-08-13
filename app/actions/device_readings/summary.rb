# frozen_string_literal: true

module Rayhub
  module Actions
    module DeviceReadings
      class Summary < Rayhub::Action
        params do
          required(:id).filled(:string)
          optional(:attributes).array(:string)
        end

        ATTRIBUTE_MAP = {
          "latest_timestamp" => "max_taken_at",
          "cumulative_count" => "quantity_sum",
        }.freeze

        def handle(request, response)
          device_id = request.params[:id]
          aggregate = Aggregates::DeviceReading::Count.find(device_id)

          attributes = request.params[:attributes]
          summary = {}

          ATTRIBUTE_MAP.each do |to, from|
            # If an `attributes` allowlist isn't present, we'll include every
            # attribute in the response.
            included = !attributes
            included ||= attributes.include?(to)
            next if !included

            value = aggregate.send(from)
            summary[to] = value
          end

          response.body = summary.to_json
          response.status = :ok
        end
      end
    end
  end
end
