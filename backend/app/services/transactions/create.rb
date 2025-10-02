# frozen_string_literal: true

module Transactions
  # Service object for creating currency conversion transactions
  # Handles: rate fetching, conversion calculation, and persistence
  class Create
    class ConversionError < StandardError; end

    def initialize(user:, exchange_rate_provider: nil)
      @user = user
      @exchange_rate_provider = exchange_rate_provider || ExchangeRateProvider.new
      @errors = []
    end

    # Create a new transaction with currency conversion
    # @param from_currency [String] Source currency code
    # @param to_currency [String] Target currency code
    # @param from_value [String, Numeric] Amount to convert
    # @return [Transaction, nil] Created transaction or nil if failed
    def call(from_currency:, to_currency:, from_value:)
      validate_input!(from_currency, to_currency, from_value)

      rate = fetch_exchange_rate(from_currency, to_currency)
      to_value = calculate_converted_value(from_value, rate)

      transaction = build_transaction(
        from_currency: from_currency,
        to_currency: to_currency,
        from_value: from_value,
        to_value: to_value,
        rate: rate
      )

      if transaction.save
        transaction
      else
        @errors = transaction.errors.full_messages
        nil
      end
    rescue ExchangeRateProvider::ApiError => e
      @errors << "Failed to fetch exchange rate: #{e.message}"
      nil
    rescue StandardError => e
      @errors << "Transaction failed: #{e.message}"
      nil
    end

    def success?
      @errors.empty?
    end

    def errors
      @errors
    end

    private

    def validate_input!(from_currency, to_currency, from_value)
      @errors = []

      if from_currency.blank?
        @errors << 'Source currency is required'
      end

      if to_currency.blank?
        @errors << 'Target currency is required'
      end

      if from_value.blank? || from_value.to_f <= 0
        @errors << 'Amount must be greater than zero'
      end

      if from_currency == to_currency
        @errors << 'Source and target currencies must be different'
      end

      raise ConversionError, @errors.join(', ') if @errors.any?
    end

    def fetch_exchange_rate(from_currency, to_currency)
      Rails.logger.info("Fetching exchange rate: #{from_currency} -> #{to_currency}")
      
      rate = @exchange_rate_provider.fetch_rate(
        from: from_currency,
        to: to_currency
      )

      Rails.logger.info("Exchange rate fetched: #{rate}")
      rate
    end

    def calculate_converted_value(from_value, rate)
      from_decimal = BigDecimal(from_value.to_s)
      converted = from_decimal * rate
      
      # Round to 4 decimal places (matching DB precision)
      converted.round(4)
    end

    def build_transaction(from_currency:, to_currency:, from_value:, to_value:, rate:)
      @user.transactions.build(
        from_currency: from_currency,
        to_currency: to_currency,
        from_value: BigDecimal(from_value.to_s),
        to_value: to_value,
        rate: rate,
        timestamp: Time.current.utc
      )
    end
  end
end
