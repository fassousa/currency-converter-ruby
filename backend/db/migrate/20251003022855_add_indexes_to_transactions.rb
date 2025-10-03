class AddIndexesToTransactions < ActiveRecord::Migration[7.1]
  def change
    # Index for user_id - most common query filter
    add_index :transactions, :user_id, if_not_exists: true
    
    # Index for timestamp - used for ordering (DESC)
    add_index :transactions, :timestamp, if_not_exists: true
    
    # Composite index for common query pattern (user + timestamp)
    add_index :transactions, [:user_id, :timestamp], if_not_exists: true, name: 'index_transactions_on_user_and_timestamp'
    
    # Index for currency pair queries (analytics/reporting)
    add_index :transactions, [:from_currency, :to_currency], if_not_exists: true, name: 'index_transactions_on_currency_pair'
  end
end
