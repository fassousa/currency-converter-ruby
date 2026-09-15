# frozen_string_literal: true

# Configure Redis for caching if REDIS_URL is provided
if ENV['REDIS_URL'].present?
  redis_config = {
    url: ENV['REDIS_URL'],
    reconnect_attempts: 1,
    reconnect_delay: 0.5,
    reconnect_delay_max: 1,
  }

  Rails.application.config.cache_store = :redis_cache_store, redis_config
end
