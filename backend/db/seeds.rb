# Dev seeds for local development
# Creates a dev user and a few example transactions.

puts "Seeding development data..."

DEV_EMAIL = ENV.fetch("DEV_USER_EMAIL", "admin@example.com")
DEV_PASSWORD = ENV.fetch("DEV_USER_PASSWORD", "password")

user = User.find_by(email: DEV_EMAIL)
unless user
  user = User.create!(email: DEV_EMAIL, password: DEV_PASSWORD)
  puts "Created dev user: #{DEV_EMAIL} / #{DEV_PASSWORD}"
else
  # If the user exists but was created before Devise was added, ensure it has a Devise password
  if user.respond_to?(:encrypted_password) && user.encrypted_password.blank?
    user.password = DEV_PASSWORD
    user.password_confirmation = DEV_PASSWORD if user.respond_to?(:password_confirmation)
    user.save!
    puts "Updated existing user #{DEV_EMAIL} with Devise password"
  else
    puts "Dev user already exists: #{DEV_EMAIL}"
  end
end

# Create a few transactions if none exist for this user
if user.transactions.count == 0
  now = Time.current.utc
  txs = [
    { from_currency: 'USD', to_currency: 'BRL', from_value: 100.0, to_value: 500.0, rate: 5.0, timestamp: now - 3.days },
    { from_currency: 'EUR', to_currency: 'USD', from_value: 50.0, to_value: 53.5, rate: 1.07, timestamp: now - 2.days },
    { from_currency: 'JPY', to_currency: 'USD', from_value: 10000.0, to_value: 67.0, rate: 0.0067, timestamp: now - 1.day }
  ]

  txs.each do |attrs|
    user.transactions.create!(attrs)
  end

  puts "Created #{txs.size} transactions for #{DEV_EMAIL}"
else
  puts "User already has #{user.transactions.count} transactions"
end

puts "Seeding complete."
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
