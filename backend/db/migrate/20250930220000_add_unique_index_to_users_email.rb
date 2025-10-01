class AddUniqueIndexToUsersEmail < ActiveRecord::Migration[7.1]
  def change
    # remove non-unique index if it exists, then add a unique index
    if index_exists?(:users, :email)
      remove_index :users, :email
    end

    add_index :users, :email, unique: true
  end
end
