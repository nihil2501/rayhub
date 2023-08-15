# frozen_string_literal: true

max_threads_count = ENV.fetch("HANAMI_MAX_THREADS", 5)
min_threads_count = ENV.fetch("HANAMI_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

port ENV.fetch("HANAMI_PORT", 2300)
environment ENV.fetch("HANAMI_ENV", "development")
# Because we are simulating state that would exist in an external DB by using
# global state, we need to only use 1 puma worker.
workers ENV.fetch("HANAMI_WEB_CONCURRENCY", 1)

on_worker_boot do
  Hanami.shutdown
end

preload_app!
