# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExchangeRateProvider, type: :service do
  let(:api_key) { ENV['CURRENCY_API_KEY'] || 'test_api_key' }
  let(:provider) { described_class.new(api_key: api_key) }
  let(:base_url) { 'https://api.currencyapi.com/v3' }

  describe '#fetch_rate' do
    context 'with valid currencies' do
      let(:from_currency) { 'USD' }
      let(:to_currency) { 'EUR' }

      it 'returns the exchange rate successfully' do
        stub_request(:get, "#{base_url}/latest")
          .with(query: hash_including('apikey' => api_key, 'base_currency' => from_currency, 'currencies' => to_currency))
          .to_return(
            status: 200,
            body: {
              data: {
                'EUR' => { 'value' => 0.85 },
              },
            }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        rate = provider.fetch_rate(from: from_currency, to: to_currency)

        expect(rate).to eq(BigDecimal('0.85'))
      end

      it 'handles decimal precision correctly' do
        stub_request(:get, "#{base_url}/latest")
          .with(query: hash_including('apikey' => api_key, 'base_currency' => 'USD', 'currencies' => 'BRL'))
          .to_return(
            status: 200,
            body: {
              data: {
                'BRL' => { 'value' => 5.257892 },
              },
            }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        rate = provider.fetch_rate(from: 'USD', to: 'BRL')

        expect(rate).to be_a(BigDecimal)
        expect(rate.to_s).to eq('5.257892')
      end
    end

    context 'when API returns an error' do
      it 'raises an error for 401 unauthorized' do
        stub_request(:get, "#{base_url}/latest")
          .with(query: hash_including('apikey' => api_key))
          .to_return(
            status: 401,
            body: { error: 'Invalid API key' }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        expect {
          provider.fetch_rate(from: 'USD', to: 'EUR')
        }.to raise_error(ExchangeRateUnavailableError, /Invalid API key/)
      end

      it 'raises an error for invalid currency' do
        expect {
          provider.fetch_rate(from: 'USD', to: 'INVALID')
        }.to raise_error(CurrencyNotSupportedError)
      end

      it 'raises an error for 500 server error' do
        stub_request(:get, "#{base_url}/latest")
          .with(query: hash_including('apikey' => api_key))
          .to_return(status: 500)

        expect {
          provider.fetch_rate(from: 'USD', to: 'EUR')
        }.to raise_error(ExchangeRateUnavailableError, /unexpected status/)
      end
    end

    context 'when API response is missing data' do
      it 'raises an error when target currency is not in response' do
        stub_request(:get, "#{base_url}/latest")
          .with(query: hash_including('apikey' => api_key))
          .to_return(
            status: 200,
            body: {
              data: {
                'GBP' => { 'value' => 0.75 },
              },
            }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        expect {
          provider.fetch_rate(from: 'USD', to: 'EUR')
        }.to raise_error(ExchangeRateUnavailableError, /No exchange rate available/)
      end

      it 'raises an error when data key is missing' do
        stub_request(:get, "#{base_url}/latest")
          .with(query: hash_including('apikey' => api_key))
          .to_return(
            status: 200,
            body: {}.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        expect {
          provider.fetch_rate(from: 'USD', to: 'EUR')
        }.to raise_error(ExchangeRateUnavailableError, /No exchange rate available/)
      end
    end

    context 'when network errors occur' do
      it 'raises an error for timeout' do
        stub_request(:get, "#{base_url}/latest")
          .with(query: hash_including('apikey' => api_key))
          .to_raise(Faraday::TimeoutError.new('execution expired'))

        expect {
          provider.fetch_rate(from: 'USD', to: 'EUR')
        }.to raise_error(ExchangeRateUnavailableError, /timeout/)
      end

      it 'raises an error for connection failure' do
        stub_request(:get, "#{base_url}/latest")
          .with(query: hash_including('apikey' => api_key))
          .to_raise(Faraday::ConnectionFailed.new('Connection refused'))

        expect {
          provider.fetch_rate(from: 'USD', to: 'EUR')
        }.to raise_error(ExchangeRateUnavailableError, /service error/)
      end
    end

    context 'with different currency pairs' do
      it 'fetches USD to BRL rate' do
        stub_request(:get, "#{base_url}/latest")
          .with(query: hash_including('apikey' => api_key, 'base_currency' => 'USD', 'currencies' => 'BRL'))
          .to_return(
            status: 200,
            body: { data: { 'BRL' => { 'value' => 5.25 } } }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        rate = provider.fetch_rate(from: 'USD', to: 'BRL')
        expect(rate).to eq(BigDecimal('5.25'))
      end

      it 'fetches EUR to JPY rate' do
        stub_request(:get, "#{base_url}/latest")
          .with(query: hash_including('apikey' => api_key, 'base_currency' => 'EUR', 'currencies' => 'JPY'))
          .to_return(
            status: 200,
            body: { data: { 'JPY' => { 'value' => 160.25 } } }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        rate = provider.fetch_rate(from: 'EUR', to: 'JPY')
        expect(rate).to eq(BigDecimal('160.25'))
      end
    end
  end
end
