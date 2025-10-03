# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :user

  # Supported currencies
  SUPPORTED_CURRENCIES = ['BRL', 'USD', 'EUR', 'JPY'].freeze

  # Validations
  validates :from_currency, presence: true, inclusion: { in: SUPPORTED_CURRENCIES }
  validates :to_currency, presence: true, inclusion: { in: SUPPORTED_CURRENCIES }
  validates :from_value, presence: true, numericality: { greater_than: 0 }
  validates :to_value, presence: true, numericality: { greater_than: 0 }
  validates :rate, presence: true, numericality: { greater_than: 0.0001 }
  validates :timestamp, presence: true

  validate :different_currencies

  # Scopes
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(timestamp: :desc) }
  scope :by_currency_pair, ->(from, to) { where(from_currency: from, to_currency: to) }

  # Callbacks
  before_validation :set_timestamp, on: :create

  private

  def different_currencies
    return unless from_currency && to_currency

    errors.add(:to_currency, 'must be different from source currency') if from_currency == to_currency
  end

  def set_timestamp
    self.timestamp ||= Time.current.utc
  end
end
