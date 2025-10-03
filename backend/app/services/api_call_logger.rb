# frozen_string_literal: true

# Service for logging external API calls
class ApiCallLogger
  class << self
    def log_request(service:, endpoint:, params: {}, headers: {})
      Rails.logger.info({
        event: 'external_api_request',
        service: service,
        endpoint: endpoint,
        params: sanitize_params(params),
        timestamp: Time.current.iso8601
      }.to_json)
    end

    def log_response(service:, endpoint:, status:, duration_ms:, success:, error: nil)
      level = success ? :info : :error
      
      Rails.logger.public_send(level, {
        event: 'external_api_response',
        service: service,
        endpoint: endpoint,
        status: status,
        duration_ms: duration_ms.round(2),
        success: success,
        error: error&.message,
        timestamp: Time.current.iso8601
      }.to_json)
    end

    def log_cache_hit(service:, cache_key:)
      Rails.logger.debug({
        event: 'cache_hit',
        service: service,
        cache_key: cache_key,
        timestamp: Time.current.iso8601
      }.to_json)
    end

    def log_cache_miss(service:, cache_key:)
      Rails.logger.debug({
        event: 'cache_miss',
        service: service,
        cache_key: cache_key,
        timestamp: Time.current.iso8601
      }.to_json)
    end

    private

    def sanitize_params(params)
      # Remove sensitive data like API keys
      params.except(:apikey, :api_key, :secret, :token, :password)
    end
  end
end
