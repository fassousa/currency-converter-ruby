module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_user!
      before_action :ensure_json_request

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActionController::ParameterMissing, with: :bad_request

      private

      def ensure_json_request
        return if request.format.json? || request.format.html?
        render json: { error: 'Unsupported Media Type' }, status: :unsupported_media_type
      end

      def not_found
        render json: { error: 'Resource not found' }, status: :not_found
      end

      def bad_request(exception)
        render json: { error: exception.message }, status: :bad_request
      end
    end
  end
end
