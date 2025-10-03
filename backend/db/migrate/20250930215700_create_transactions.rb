class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :from_currency, null: false
      t.string :to_currency, null: false
      t.decimal :from_value, precision: 12, scale: 4, null: false
      t.decimal :to_value, precision: 12, scale: 4, null: false
      t.decimal :rate, precision: 12, scale: 8, null: false
      t.datetime :timestamp, null: false

      t.timestamps
    end
    add_index :transactions, :timestamp
    add_index :transactions, [:from_currency, :to_currency]
  end
end
