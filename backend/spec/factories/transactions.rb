# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    association :user
    
    from_currency { 'USD' }
    to_currency { 'EUR' }
    from_value { BigDecimal('100.00') }
    rate { BigDecimal('0.85') }
    to_value { BigDecimal('85.00') }
    timestamp { Time.current.utc }
    
    trait :usd_to_brl do
      from_currency { 'USD' }
      to_currency { 'BRL' }
      from_value { BigDecimal('100.00') }
      rate { BigDecimal('5.25') }
      to_value { BigDecimal('525.00') }
    end
    
    trait :eur_to_jpy do
      from_currency { 'EUR' }
      to_currency { 'JPY' }
      from_value { BigDecimal('50.00') }
      rate { BigDecimal('160.25') }
      to_value { BigDecimal('8012.50') }
    end
  end
end
