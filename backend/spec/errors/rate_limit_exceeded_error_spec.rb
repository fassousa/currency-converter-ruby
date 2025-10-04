# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateLimitExceededError do
  it 'has correct defaults and handles retry_after' do # rubocop:disable RSpec/MultipleExpectations
    error = described_class.new
    expect(error.message).to eq('API rate limit exceeded. Please try again later.')
    expect(error.status).to eq(:too_many_requests)
    expect(error.error_code).to eq('rate_limit_exceeded')
    expect(error.retry_after).to be_nil

    with_retry = described_class.new(retry_after: 60, message: 'Custom', details: { limit: 100 })
    expect(with_retry.message).to eq('Custom')
    expect(with_retry.retry_after).to eq(60)
    expect(with_retry.details).to include(retry_after: 60, limit: 100)
  end

  it 'serializes to hash with retry_after' do
    hash = described_class.new(retry_after: 60).to_h
    expect(hash[:error]).to include(type: 'rate_limit_exceeded', details: include(retry_after: 60))
  end
end
