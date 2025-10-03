module Api
  module V1
    module ErrorResponses
      extend ActiveSupport::Concern

      included do
        rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
        rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
        rescue_from ActionController::ParameterMissing, with: :render_bad_request
      end

      private

      def render_error(message, status, code = nil)
        render json: {
          error: {
            message: message,
            code: code || status.to_s,
            status: Rack::Utils.status_code(status)
          }
        }, status: status
      end

      def render_not_found(exception)
        render_error(exception.message, :not_found, 'RESOURCE_NOT_FOUND')
      end

      def render_unprocessable_entity(exception)
        render_error(exception.message, :unprocessable_entity, 'VALIDATION_ERROR')
      end

      def render_bad_request(exception)
        render_error(exception.message, :bad_request, 'BAD_REQUEST')
      end

      def render_unauthorized(message = 'Unauthorized')
        render_error(message, :unauthorized, 'UNAUTHORIZED')
      end
    end
  end
end
