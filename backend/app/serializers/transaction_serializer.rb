# frozen_string_literal: true

class TransactionSerializer
  def initialize(transaction)
    @transaction = transaction
  end

  def as_json
    {
      id: @transaction.id,
      from_currency: @transaction.from_currency,
      to_currency: @transaction.to_currency,
      from_value: @transaction.from_value.to_s,
      to_value: @transaction.to_value.to_s,
      rate: @transaction.rate.to_s,
      timestamp: @transaction.timestamp.iso8601,
    }
  end

  def self.collection(transactions)
    transactions.map { |transaction| new(transaction).as_json }
  end
end
