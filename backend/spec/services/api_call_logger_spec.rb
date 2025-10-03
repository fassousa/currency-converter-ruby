# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiCallLogger do
  describe '.log_request' do
    it 'logs request with params and sanitizes sensitive keys' do
      allow(Rails.logger).to receive(:info)
      described_class.log_request(service: 'API', endpoint: '/rates', params: { from: 'USD', apikey: 'secret' })

      expect(Rails.logger).to have_received(:info) do |msg|
        json = JSON.parse(msg)
        expect(json).to include('event' => 'external_api_request', 'service' => 'API', 'endpoint' => '/rates')
        expect(json['params']).to eq({ 'from' => 'USD' })
      end
    end
  end

  describe '.log_response' do
    it 'logs success with info and failure with error level' do
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)

      described_class.log_response(service: 'API', endpoint: '/rates', status: 200, duration_ms: 123.456, success: true)
      expect(Rails.logger).to have_received(:info) do |msg|
        json = JSON.parse(msg)
        expect(json).to include('event' => 'external_api_response', 'status' => 200, 'duration_ms' => 123.46, 'success' => true)
      end

      described_class.log_response(service: 'API', endpoint: '/rates', status: 500, duration_ms: 50.5, success: false, error: StandardError.new('Failed'))
      expect(Rails.logger).to have_received(:error) do |msg|
        json = JSON.parse(msg)
        expect(json).to include('success' => false, 'error' => 'Failed')
      end
    end
  end

  describe 'cache logging' do
    it 'logs cache hit and miss events' do
      allow(Rails.logger).to receive(:debug)

      described_class.log_cache_hit(service: 'Provider', cache_key: 'rate:USD:EUR')
      expect(Rails.logger).to have_received(:debug).with(include('cache_hit'))

      described_class.log_cache_miss(service: 'Provider', cache_key: 'rate:USD:EUR')
      expect(Rails.logger).to have_received(:debug).with(include('cache_miss'))
    end
  end
end
