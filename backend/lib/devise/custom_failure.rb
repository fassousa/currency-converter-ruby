# frozen_string_literal: true

module Devise
  class CustomFailure < Devise::FailureApp
    def respond
      if api_request?
        json_api_error_response
      else
        super
      end
    end

    def json_api_error_response
      self.status = 401
      self.content_type = 'application/json'
      self.response_body = { error: 'Unauthorized' }.to_json
    end

    # Skip store_location for API requests
    def store_location!
      return if api_request?

      super
    end

    private

    def api_request?
      request.content_type == 'application/json' || request.path.start_with?('/api/')
    end
  end
end
