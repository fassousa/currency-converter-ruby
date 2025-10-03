# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_10_03_022855) do
  create_table "transactions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "from_currency", null: false
    t.string "to_currency", null: false
    t.decimal "from_value", precision: 12, scale: 4, null: false
    t.decimal "to_value", precision: 12, scale: 4, null: false
    t.decimal "rate", precision: 12, scale: 8, null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_currency", "to_currency"], name: "index_transactions_on_currency_pair"
    t.index ["from_currency", "to_currency"], name: "index_transactions_on_from_currency_and_to_currency"
    t.index ["timestamp"], name: "index_transactions_on_timestamp"
    t.index ["user_id", "timestamp"], name: "index_transactions_on_user_and_timestamp"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "jti"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "transactions", "users"
end
