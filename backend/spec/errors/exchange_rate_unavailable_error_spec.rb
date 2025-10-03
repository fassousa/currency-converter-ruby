# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExchangeRateUnavailableError do
  it 'has correct defaults and accepts custom values' do
    error = described_class.new
    expect(error.message).to eq('Exchange rate data is currently unavailable')
    expect(error.status).to eq(:service_unavailable)
    expect(error.error_code).to eq('exchange_rate_unavailable')

    custom = described_class.new(message: 'API down', details: { reason: 'timeout' })
    expect(custom.message).to eq('API down')
    expect(custom.details[:reason]).to eq('timeout')
  end

  it 'serializes to hash correctly' do
    hash = described_class.new.to_h
    expect(hash[:error]).to include(type: 'exchange_rate_unavailable', message: 'Exchange rate data is currently unavailable')
  end
end
