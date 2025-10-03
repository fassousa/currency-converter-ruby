# Configure Redis for caching
redis_config = {
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
  reconnect_attempts: 1,
  reconnect_delay: 0.5,
  reconnect_delay_max: 1
}

Rails.application.config.cache_store = :redis_cache_store, redis_config
