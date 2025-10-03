# Lograge configuration for structured JSON logging
Rails.application.configure do
  # Enable Lograge
  config.lograge.enabled = true

  # Use JSON formatter for structured logs
  config.lograge.formatter = Lograge::Formatters::Json.new

  # Custom options to include in logs
  config.lograge.custom_options = lambda do |event|
    {
      time: Time.current,
      remote_ip: event.payload[:remote_ip],
      user_id: event.payload[:user_id],
      request_id: event.payload[:request_id],
      params: event.payload[:params]&.except('controller', 'action', 'format'),
      exception: event.payload[:exception]&.first,
      exception_message: event.payload[:exception]&.last
    }.compact
  end

  # Include custom payload fields
  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      remote_ip: controller.request.remote_ip,
      user_id: controller.current_user&.id,
      request_id: controller.request.uuid
    }
  end
end
