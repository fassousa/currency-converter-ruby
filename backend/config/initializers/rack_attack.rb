# frozen_string_literal: true

# Rack::Attack configuration for rate limiting and security
module Rack
  class Attack
    ### Configure Cache ###
    # Use Rails.cache by default (Redis recommended for production)
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    ### Throttle Configuration ###

    # Skip rate limiting in test environment
    unless Rails.env.test?
      # Throttle all requests by IP (100 req/minute)
      throttle('req/ip', limit: 100, period: 1.minute, &:ip)

      # Throttle login attempts by IP address
      throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
        req.ip if req.path == '/api/v1/auth/sign_in' && req.post?
      end

      # Throttle login attempts by email address
      throttle('logins/email', limit: 5, period: 20.seconds) do |req|
        if req.path == '/api/v1/auth/sign_in' && req.post?
          # Return the email if present in POST data
          user_params = req.params['user']
          email = user_params&.dig('email')
          email&.to_s&.downcase&.presence
        end
      end
    end

    # Block suspicious requests
    blocklist('fail2ban pentesters') do |req|
      # Block if returning more than 10 forbidden responses in 10 minutes
      # This helps protect against automated scanners
      Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 10, findtime: 10.minutes, bantime: 1.hour) do
        # The count is incremented if the return value is truthy
        CGI.unescape(req.query_string).include?('/etc/passwd') ||
          req.path.include?('/etc/passwd') ||
          req.path.include?('wp-admin') ||
          req.path.include?('wp-login')
      end
    end

    ### Custom Throttle Response ###
    self.throttled_responder = lambda do |request|
      match_data = request.env['rack.attack.match_data']
      now = match_data[:epoch_time]

      headers = {
        'Content-Type' => 'application/json',
        'X-RateLimit-Limit' => match_data[:limit].to_s,
        'X-RateLimit-Remaining' => '0',
        'X-RateLimit-Reset' => (now + (match_data[:period] - (now % match_data[:period]))).to_s,
      }

      [429, headers, [{ error: 'Rate limit exceeded. Please try again later.' }.to_json]]
    end
  end
end
