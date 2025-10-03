# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    association :user

    from_currency do
      'USD'
    end
    to_currency do
      'EUR'
    end
    from_value do
      BigDecimal('100.00')
    end
    rate do
      BigDecimal('0.85')
    end
    to_value do
      BigDecimal('85.00')
    end
    timestamp do
      Time.current.utc
    end

    trait :usd_to_brl do
      from_currency do
        'USD'
      end
      to_currency do
        'BRL'
      end
      from_value do
        BigDecimal('100.00')
      end
      rate do
        BigDecimal('5.25')
      end
      to_value { BigDecimal('525.00') }
    end

    trait :eur_to_jpy do
      from_currency do
        'EUR'
      end
      to_currency do
        'JPY'
      end
      from_value do
        BigDecimal('50.00')
      end
      rate do
        BigDecimal('160.25')
      end
      to_value { BigDecimal('8012.50') }
    end
  end
end
