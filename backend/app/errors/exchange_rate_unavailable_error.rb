# frozen_string_literal: true

# Error raised when exchange rate data is unavailable
class ExchangeRateUnavailableError < ApplicationError
  def initialize(message: nil, details: {})
    super(
      message || 'Exchange rate data is currently unavailable',
      status: :service_unavailable,
      error_code: 'exchange_rate_unavailable',
      details: details
    )
  end

  private

  def default_message
    'Exchange rate data is currently unavailable'
  end
end
