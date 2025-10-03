# frozen_string_literal: true

# Service class for fetching exchange rates from CurrencyAPI
# Implements retry logic, timeout handling, and error management
class ExchangeRateProvider
  class ApiError < StandardError; end
  class RateLimitError < ApiError; end
  class InvalidCurrencyError < ApiError; end
  class TimeoutError < ApiError; end

  BASE_URL = 'https://api.currencyapi.com/v3'
  TIMEOUT_SECONDS = 10
  MAX_RETRIES = 3
  CACHE_EXPIRATION = 24.hours # Cache rates for 24 hours

  def initialize(api_key: nil)
    @api_key = api_key || ENV.fetch('CURRENCY_API_KEY', nil)
    raise ArgumentError, 'CURRENCY_API_KEY is required' if @api_key.blank?
  end

  # Fetch the latest exchange rate for a specific currency pair with caching
  # @param from [String] Source currency code (e.g., 'USD')
  # @param to [String] Target currency code (e.g., 'BRL')
  # @return [BigDecimal] Exchange rate
  def fetch_rate(from:, to:)
    validate_currencies!(from, to)

    # If same currency, rate is 1
    return BigDecimal('1.0') if from == to

    # Try to fetch from cache first
    cache_key = rate_cache_key(from, to)
    cached_rate = Rails.cache.read(cache_key)
    
    if cached_rate
      ApiCallLogger.log_cache_hit(service: 'CurrencyAPI', cache_key: cache_key)
      return BigDecimal(cached_rate)
    end

    ApiCallLogger.log_cache_miss(service: 'CurrencyAPI', cache_key: cache_key)

    # Fetch from API and cache the result
    start_time = Time.current
    response = fetch_latest_rates(base_currency: from, currencies: [to])
    duration_ms = (Time.current - start_time) * 1000
    
    rate = parse_rate(response, from, to)
    Rails.cache.write(cache_key, rate.to_s, expires_in: CACHE_EXPIRATION)
    
    ApiCallLogger.log_response(
      service: 'CurrencyAPI',
      endpoint: '/latest',
      status: 200,
      duration_ms: duration_ms,
      success: true
    )
    
    rate
  rescue Faraday::TimeoutError => e
    ApiCallLogger.log_response(
      service: 'CurrencyAPI',
      endpoint: '/latest',
      status: 0,
      duration_ms: (Time.current - start_time) * 1000,
      success: false,
      error: e
    )
    raise TimeoutError, "CurrencyAPI timeout: #{e.message}"
  rescue Faraday::Error => e
    ApiCallLogger.log_response(
      service: 'CurrencyAPI',
      endpoint: '/latest',
      status: 0,
      duration_ms: (Time.current - start_time) * 1000,
      success: false,
      error: e
    )
    raise ApiError, "CurrencyAPI error: #{e.message}"
  end

  # Fetch multiple exchange rates at once
  # @param from [String] Source currency code
  # @param to_currencies [Array<String>] Array of target currency codes
  # @return [Hash] Hash with currency codes as keys and rates as values
  def fetch_rates(from:, to_currencies:)
    validate_currencies!(from, *to_currencies)

    response = fetch_latest_rates(base_currency: from, currencies: to_currencies)
    parse_multiple_rates(response, from, to_currencies)
  rescue Faraday::TimeoutError => e
    raise TimeoutError, "CurrencyAPI timeout: #{e.message}"
  rescue Faraday::Error => e
    raise ApiError, "CurrencyAPI error: #{e.message}"
  end

  private

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |conn|
      conn.request :url_encoded
      conn.request :retry, {
        max: MAX_RETRIES,
        interval: 0.5,
        interval_randomness: 0.5,
        backoff_factor: 2,
        retry_statuses: [429, 500, 502, 503, 504],
        methods: [:get]
      }
      conn.response :json, content_type: /\bjson$/
      conn.adapter Faraday.default_adapter
      conn.options.timeout = TIMEOUT_SECONDS
      conn.options.open_timeout = TIMEOUT_SECONDS
    end
  end

  # CurrencyAPI endpoint: /latest
  # Returns latest exchange rates for specified currencies
  def fetch_latest_rates(base_currency:, currencies:)
    ApiCallLogger.log_request(
      service: 'CurrencyAPI',
      endpoint: '/latest',
      params: { base_currency: base_currency, currencies: currencies.join(',') }
    )

    response = connection.get('latest') do |req|
      req.params['apikey'] = @api_key
      req.params['base_currency'] = base_currency
      req.params['currencies'] = currencies.join(',')
    end

    handle_api_response(response)
  end

  def handle_api_response(response)
    case response.status
    when 200
      response.body
    when 401
      raise ApiError, 'Invalid API key'
    when 422
      raise InvalidCurrencyError, 'Invalid currency code'
    when 429
      raise RateLimitError, 'API rate limit exceeded'
    else
      raise ApiError, "API returned status #{response.status}"
    end
  end

  def parse_rate(response_body, from, to)
    data = response_body.dig('data', to)
    
    if data.nil?
      raise ApiError, "No rate found for #{from} -> #{to}"
    end

    rate_value = data['value']
    BigDecimal(rate_value.to_s)
  end

  def parse_multiple_rates(response_body, from, to_currencies)
    rates = {}
    
    to_currencies.each do |currency|
      data = response_body.dig('data', currency)
      
      if data
        rates[currency] = BigDecimal(data['value'].to_s)
      else
        rates[currency] = nil
      end
    end

    rates
  end

  def validate_currencies!(*currencies)
    valid_currencies = Transaction::SUPPORTED_CURRENCIES
    
    currencies.each do |currency|
      unless valid_currencies.include?(currency)
        raise InvalidCurrencyError, "Unsupported currency: #{currency}. Valid currencies: #{valid_currencies.join(', ')}"
      end
    end
  end

  def rate_cache_key(from, to)
    "exchange_rate:#{from}:#{to}:#{Date.current.strftime('%Y-%m-%d')}"
  end
end
