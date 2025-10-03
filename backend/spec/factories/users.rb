# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    
    trait :with_transactions do
      after(:create) do |user|
        create_list(:transaction, 3, user: user)
      end
    end
  end
end
