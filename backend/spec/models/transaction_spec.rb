# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'constants' do
    it 'defines and freezes supported currencies' do
      expect(Transaction::SUPPORTED_CURRENCIES).to eq(%w[BRL USD EUR JPY]).and be_frozen
    end
  end

  describe 'validations' do
    subject { build(:transaction) }

    describe 'currency validations' do
      it { is_expected.to validate_presence_of(:from_currency) }
      it { is_expected.to validate_presence_of(:to_currency) }

      it 'validates currencies are in supported list' do
        expect(build(:transaction, from_currency: 'INVALID')).not_to be_valid
        expect(build(:transaction, to_currency: 'INVALID')).not_to be_valid
      end

      it 'allows all supported currencies' do
        Transaction::SUPPORTED_CURRENCIES.each do |currency|
          other = Transaction::SUPPORTED_CURRENCIES.reject { |c| c == currency }.first
          expect(build(:transaction, from_currency: currency, to_currency: other)).to be_valid
        end
      end

      it 'validates currencies must be different' do
        transaction = build(:transaction, from_currency: 'USD', to_currency: 'USD')
        expect(transaction).not_to be_valid
        expect(transaction.errors[:to_currency]).to include('must be different from source currency')
      end
    end

    describe 'numeric validations' do
      it { is_expected.to validate_presence_of(:from_value) }
      it { is_expected.to validate_presence_of(:to_value) }
      it { is_expected.to validate_presence_of(:rate) }

      it { is_expected.to validate_numericality_of(:from_value).is_greater_than(0) }
      it { is_expected.to validate_numericality_of(:to_value).is_greater_than(0) }
      it { is_expected.to validate_numericality_of(:rate).is_greater_than(0.0001) }
    end

    describe 'timestamp validation' do
      # NOTE: timestamp is auto-set by before_validation callback, so presence validation will always pass
      it 'auto-sets timestamp when nil' do
        transaction = build(:transaction, timestamp: nil)
        transaction.valid?
        expect(transaction.timestamp).to be_present
      end
    end
  end

  describe 'callbacks' do
    it 'sets timestamp before validation when nil' do
      transaction = build(:transaction, timestamp: nil)
      transaction.valid?
      expect(transaction.timestamp).to be_present
    end

    it 'preserves existing timestamp' do
      custom_time = 1.day.ago
      transaction = build(:transaction, timestamp: custom_time)
      transaction.valid?
      expect(transaction.timestamp).to be_within(1.second).of(custom_time)
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }

    describe '.by_user' do
      it 'returns transactions for specific user' do
        user_transaction = create(:transaction, user: user)
        other_transaction = create(:transaction)

        result = described_class.by_user(user.id)
        expect(result).to include(user_transaction)
        expect(result).not_to include(other_transaction)
      end
    end

    describe '.recent' do
      it 'orders transactions by timestamp descending' do
        old = create(:transaction, timestamp: 2.days.ago)
        recent = create(:transaction, timestamp: 1.hour.ago)
        newest = create(:transaction, timestamp: 5.minutes.ago)

        expect(described_class.recent).to eq([newest, recent, old])
      end
    end

    describe '.by_currency_pair' do
      it 'filters by specific currency pair' do
        usd_brl = create(:transaction, from_currency: 'USD', to_currency: 'BRL')
        create(:transaction, from_currency: 'EUR', to_currency: 'JPY')

        result = described_class.by_currency_pair('USD', 'BRL')
        expect(result).to eq([usd_brl])
      end
    end

    it 'chains scopes correctly' do
      user1 = create(:user)
      old_tx = create(:transaction, user: user1, from_currency: 'USD', to_currency: 'BRL', timestamp: 2.days.ago)
      recent_tx = create(:transaction, user: user1, from_currency: 'USD', to_currency: 'BRL', timestamp: 1.hour.ago)
      create(:transaction, user: create(:user), from_currency: 'USD', to_currency: 'BRL')

      result = described_class.by_user(user1.id).by_currency_pair('USD', 'BRL').recent
      expect(result).to eq([recent_tx, old_tx])
    end
  end

  describe 'decimal precision' do
    it 'stores values with correct decimal places' do
      transaction = create(:transaction, from_value: 100.12345, to_value: 525.56789, rate: 5.123456789)
      transaction.reload

      expect(transaction.from_value).to eq(BigDecimal('100.1235'))
      expect(transaction.to_value).to eq(BigDecimal('525.5679'))
      expect(transaction.rate).to eq(BigDecimal('5.12345679'))
    end
  end

  describe 'database constraints' do
    it 'enforces user foreign key constraint' do
      transaction = build(:transaction)
      transaction.user_id = 999_999
      expect { transaction.save(validate: false) }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end
end
