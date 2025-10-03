# frozen_string_literal: true

# Base class for all custom application errors
class ApplicationError < StandardError
  attr_reader :status, :error_code, :details

  def initialize(message = nil, status: :internal_server_error, error_code: nil, details: {})
    @status = status
    @error_code = error_code || self.class.name.demodulize.underscore
    @details = details
    super(message || default_message)
  end

  def to_h
    {
      error: {
        type: error_code,
        message: message,
        details: details,
      }.compact,
    }
  end

  def http_status
    status
  end

  private

  def default_message
    'An error occurred'
  end
end
