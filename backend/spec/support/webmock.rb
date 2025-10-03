# frozen_string_literal: true

require 'webmock/rspec'

# Disable all real HTTP connections except localhost
WebMock.disable_net_connect!(allow_localhost: true)

# Reset WebMock stubs after each test
RSpec.configure do |config|
  config.after do
    WebMock.reset!
  end
end
