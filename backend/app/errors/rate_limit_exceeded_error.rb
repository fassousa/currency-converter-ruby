# frozen_string_literal: true

# Error raised when API rate limit is exceeded
class RateLimitExceededError < ApplicationError
  def initialize(message: nil, retry_after: nil, details: {})
    @retry_after = retry_after
    details_with_retry = details.merge(retry_after: retry_after).compact

    super(
      message || 'API rate limit exceeded. Please try again later.',
      status: :too_many_requests,
      error_code: 'rate_limit_exceeded',
      details: details_with_retry
    )
  end

  attr_reader :retry_after

  private

  def default_message
    'API rate limit exceeded. Please try again later.'
  end
end
