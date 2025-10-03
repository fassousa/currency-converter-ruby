# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrencyNotSupportedError do
  it 'has correct attributes and supports custom message' do
    error = described_class.new('XYZ')
    expect(error.message).to eq("Currency 'XYZ' is not supported")
    expect(error.status).to eq(:unprocessable_entity)
    expect(error.error_code).to eq('currency_not_supported')
    expect(error.details).to include(currency: 'XYZ', supported_currencies: Transaction::SUPPORTED_CURRENCIES)

    custom = described_class.new('ABC', message: 'Custom')
    expect(custom.message).to eq('Custom')
  end

  it 'serializes to hash with all details' do
    hash = described_class.new('ABC').to_h
    expect(hash[:error]).to include(type: 'currency_not_supported')
    expect(hash[:error][:message]).to include('ABC')
    expect(hash[:error][:details][:supported_currencies]).to be_an(Array)
  end
end
