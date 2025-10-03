# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include ErrorResponses

      before_action :authenticate_user!
      before_action :ensure_json_request

      private

      def ensure_json_request
        return if request.format.json? || request.format.html?

        render json: { error: 'Unsupported Media Type' }, status: :unsupported_media_type
      end
    end
  end
end
