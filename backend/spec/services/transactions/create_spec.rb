# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transactions::Create, type: :service do
  let(:user) { create(:user) }
  let(:exchange_rate_provider) { instance_double(ExchangeRateProvider) }
  let(:service) { described_class.new(user: user, exchange_rate_provider: exchange_rate_provider) }

  describe '#call' do
    context 'with valid parameters' do
      before do
        allow(exchange_rate_provider).to receive(:fetch_rate)
          .with(from: 'USD', to: 'EUR')
          .and_return(BigDecimal('0.85'))
      end

      it 'creates a transaction successfully' do
        expect do
          service.call(from_currency: 'USD', to_currency: 'EUR', from_value: '100.00')
        end.to change(Transaction, :count).by(1)
      end

      it 'returns the created transaction' do
        transaction = service.call(from_currency: 'USD', to_currency: 'EUR', from_value: '100.00')

        expect(transaction).to be_a(Transaction)
        expect(transaction).to be_persisted
        expect(transaction.user).to eq(user)
      end

      it 'sets the correct attributes' do
        transaction = service.call(from_currency: 'USD', to_currency: 'EUR', from_value: '100.00')

        expect(transaction.from_currency).to eq('USD')
        expect(transaction.to_currency).to eq('EUR')
        expect(transaction.from_value).to eq(BigDecimal('100.00'))
        expect(transaction.rate).to eq(BigDecimal('0.85'))
        expect(transaction.to_value).to eq(BigDecimal('85.00'))
      end

      it 'calculates the converted amount correctly' do
        transaction = service.call(from_currency: 'USD', to_currency: 'EUR', from_value: '100.00')

        expect(transaction.to_value).to eq(
          transaction.from_value * transaction.rate,
        )
      end

      it 'fetches the exchange rate from the provider' do
        allow(exchange_rate_provider).to receive(:fetch_rate)
          .with(from: 'USD', to: 'EUR')
          .and_return(BigDecimal('0.85'))

        service.call(from_currency: 'USD', to_currency: 'EUR', from_value: '100.00')

        expect(exchange_rate_provider).to have_received(:fetch_rate)
          .with(from: 'USD', to: 'EUR')
      end

      it 'persists the transaction correctly' do
        transaction = service.call(from_currency: 'USD', to_currency: 'EUR', from_value: '100.00')
        expect(transaction).to be_a(Transaction)
        expect(transaction.persisted?).to be true
      end
    end

    context 'with different currency pairs' do
      it 'handles USD to BRL conversion' do
        allow(exchange_rate_provider).to receive(:fetch_rate)
          .with(from: 'USD', to: 'BRL')
          .and_return(BigDecimal('5.25'))

        transaction = service.call(
          from_currency: 'USD',
          to_currency: 'BRL',
          from_value: '100.00',
        )

        expect(transaction.from_currency).to eq('USD')
        expect(transaction.to_currency).to eq('BRL')
        expect(transaction.rate).to eq(BigDecimal('5.25'))
        expect(transaction.to_value).to eq(BigDecimal('525.00'))
      end

      it 'handles EUR to JPY conversion' do
        allow(exchange_rate_provider).to receive(:fetch_rate)
          .with(from: 'EUR', to: 'JPY')
          .and_return(BigDecimal('160.25'))

        transaction = service.call(
          from_currency: 'EUR',
          to_currency: 'JPY',
          from_value: '50.00',
        )

        expect(transaction.to_value).to eq(BigDecimal('8012.5'))
      end
    end

    context 'with decimal amounts' do
      it 'handles amounts with many decimal places and rounds to 4 decimals' do
        allow(exchange_rate_provider).to receive(:fetch_rate)
          .and_return(BigDecimal('0.857342'))

        transaction = service.call(
          from_currency: 'USD',
          to_currency: 'EUR',
          from_value: '123.4568',
        )

        expect(transaction.from_value).to eq(BigDecimal('123.4568'))
        # 123.4568 * 0.857342 = 105.8447... rounded to 4 decimals = 105.8447
        expect(transaction.to_value).to eq(BigDecimal('105.8447'))
      end
    end

    context 'when from_currency is missing' do
      it 'raises ApplicationError' do
        expect do
          service.call(
            from_currency: '',
            to_currency: 'EUR',
            from_value: '100',
          )
        end.to raise_error(ApplicationError, /Source currency is required/)
      end
    end

    context 'when to_currency is missing' do
      it 'raises ApplicationError' do
        expect do
          service.call(
            from_currency: 'USD',
            to_currency: '',
            from_value: '100',
          )
        end.to raise_error(ApplicationError, /Target currency is required/)
      end
    end

    context 'when from_value is invalid' do
      it 'raises ApplicationError for negative amount' do
        expect do
          service.call(
            from_currency: 'USD',
            to_currency: 'EUR',
            from_value: '-100',
          )
        end.to raise_error(ApplicationError, /Amount must be greater than zero/)
      end

      it 'raises ApplicationError for zero amount' do
        expect do
          service.call(
            from_currency: 'USD',
            to_currency: 'EUR',
            from_value: '0',
          )
        end.to raise_error(ApplicationError, /Amount must be greater than zero/)
      end

      it 'raises ApplicationError for blank amount' do
        expect do
          service.call(
            from_currency: 'USD',
            to_currency: 'EUR',
            from_value: '',
          )
        end.to raise_error(ApplicationError, /Amount must be greater than zero/)
      end
    end

    context 'when currencies are the same' do
      it 'raises ApplicationError' do
        expect do
          service.call(
            from_currency: 'USD',
            to_currency: 'USD',
            from_value: '100',
          )
        end.to raise_error(ApplicationError, /Source and target currencies must be different/)
      end
    end

    context 'when exchange rate provider fails' do
      it 'raises ExchangeRateUnavailableError' do
        allow(exchange_rate_provider).to receive(:fetch_rate)
          .and_raise(ExchangeRateUnavailableError.new(message: 'API error'))

        expect do
          service.call(
            from_currency: 'USD',
            to_currency: 'EUR',
            from_value: '100',
          )
        end.to raise_error(ExchangeRateUnavailableError, /API error/)
      end

      it 'does not create a transaction' do
        allow(exchange_rate_provider).to receive(:fetch_rate)
          .and_raise(ExchangeRateUnavailableError.new(message: 'API error'))

        expect do
          expect do
            service.call(
              from_currency: 'USD',
              to_currency: 'EUR',
              from_value: '100',
            )
          end.to raise_error(ExchangeRateUnavailableError)
        end.not_to change(Transaction, :count)
      end
    end
  end
end
