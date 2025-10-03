# frozen_string_literal: true

# Middleware for performance monitoring and slow request logging
class PerformanceMonitoring
  SLOW_REQUEST_THRESHOLD = 1000 # milliseconds

  def initialize(app)
    @app = app
  end

  def call(env)
    start_time = Time.current
    request = ActionDispatch::Request.new(env)

    status, headers, response = @app.call(env)

    duration_ms = ((Time.current - start_time) * 1000).round(2)

    log_performance(request, status, duration_ms) if should_log?(request, duration_ms)

    [status, headers, response]
  end

  private

  def should_log?(request, duration_ms)
    # Log API requests and slow requests
    request.path.start_with?('/api/') || duration_ms >= SLOW_REQUEST_THRESHOLD
  end

  def log_performance(request, status, duration_ms)
    level = duration_ms >= SLOW_REQUEST_THRESHOLD ? :warn : :info

    Rails.logger.public_send(level, {
      event: 'performance_monitoring',
      method: request.method,
      path: request.fullpath,
      status: status,
      duration_ms: duration_ms,
      slow_request: duration_ms >= SLOW_REQUEST_THRESHOLD,
      threshold_ms: SLOW_REQUEST_THRESHOLD,
      db_runtime_ms: db_runtime,
      view_runtime_ms: view_runtime,
      timestamp: Time.current.iso8601,
    }.to_json,)
  end

  def db_runtime
    # This will be populated by ActiveSupport::Notifications
    Thread.current[:db_runtime]&.round(2)
  end

  def view_runtime
    # This will be populated by ActiveSupport::Notifications
    Thread.current[:view_runtime]&.round(2)
  end
end
