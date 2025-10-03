# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionSerializer do
  let(:user) { create(:user) }
  let(:transaction) do
    create(:transaction, user: user, from_currency: 'USD', to_currency: 'EUR',
                         from_value: BigDecimal('100.00'), to_value: BigDecimal('85.50'), rate: BigDecimal('0.855'),)
  end

  describe '#as_json' do
    subject(:json) { described_class.new(transaction).as_json }

    it 'serializes all attributes correctly' do
      expect(json).to include(
        id: transaction.id,
        from_currency: 'USD',
        to_currency: 'EUR',
        from_value: '100.0',
        to_value: '85.5',
        rate: '0.855',
        timestamp: transaction.timestamp.iso8601,
      )
    end

    it 'preserves decimal precision in strings' do
      precise = create(:transaction, user: user, from_value: BigDecimal('100.5678'),
                                     to_value: BigDecimal('85.1234'), rate: BigDecimal('0.84567890'),)
      json = described_class.new(precise).as_json
      expect(json.values_at(:from_value, :to_value, :rate)).to all(match(/\d+\.\d+/))
    end
  end

  describe '.collection' do
    it 'serializes multiple transactions' do
      transactions = create_list(:transaction, 3, user: user)
      serialized = described_class.collection(transactions)

      expect(serialized).to be_an(Array).and have_attributes(size: 3)
      expect(serialized.first.keys).to match_array(%i[id from_currency to_currency from_value to_value rate timestamp])
    end
  end
end
