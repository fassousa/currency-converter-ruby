namespace :cache do
  desc "Warm up exchange rate cache for all currency pairs"
  task warm_rates: :environment do
    currencies = Transaction::SUPPORTED_CURRENCIES
    provider = ExchangeRateProvider.new
    
    puts "Warming up exchange rate cache..."
    puts "Supported currencies: #{currencies.join(', ')}"
    
    currencies.each do |from_currency|
      currencies.each do |to_currency|
        next if from_currency == to_currency
        
        begin
          rate = provider.fetch_rate(from: from_currency, to: to_currency)
          puts "✓ Cached #{from_currency} → #{to_currency}: #{rate}"
        rescue => e
          puts "✗ Failed #{from_currency} → #{to_currency}: #{e.message}"
        end
      end
    end
    
    puts "\nCache warming complete!"
  end
  
  desc "Clear all exchange rate caches"
  task clear_rates: :environment do
    puts "Clearing exchange rate caches..."
    Rails.cache.delete_matched("exchange_rate:*")
    puts "Cache cleared!"
  end
end
