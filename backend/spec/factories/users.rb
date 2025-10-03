# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email do
      Faker::Internet.unique.email
    end
    password do
      'password123'
    end
    password_confirmation do
      'password123'
    end

    trait :with_transactions do
      after(:create) do |user|
        create_list(:transaction, 3, user: user)
      end
    end
  end
end
