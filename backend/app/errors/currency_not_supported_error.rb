# frozen_string_literal: true

# Error raised when an unsupported currency is requested
class CurrencyNotSupportedError < ApplicationError
  def initialize(currency, message: nil)
    @currency = currency
    super(
      message || "Currency '#{currency}' is not supported",
      status: :unprocessable_entity,
      error_code: 'currency_not_supported',
      details: {
        currency: currency,
        supported_currencies: Transaction::SUPPORTED_CURRENCIES,
      }
    )
  end

  private

  def default_message
    "Currency '#{@currency}' is not supported"
  end
end
