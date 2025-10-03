class AddDeviseToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      # Devise expects encrypted_password (string, not null, default: "")
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      # Other Devise columns can be added as needed (confirmable, trackable, lockable)
    end

    # Remove legacy password_digest if present
    if column_exists?(:users, :password_digest)
      remove_column :users, :password_digest
    end

    add_index :users, :reset_password_token, unique: true
  end
end
