# frozen_string_literal: true

module Api
  module V1
    module ErrorResponses
      extend ActiveSupport::Concern

      included do
        #  Catch-all for unexpected errors (except in development) - must be first so more specific handlers take precedence
        rescue_from StandardError, with: :render_internal_error unless Rails.env.development?

        # ActiveRecord errors
        rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
        rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
        rescue_from ActionController::ParameterMissing, with: :render_bad_request

        # Custom application errors - more specific ones last so they take precedence
        rescue_from ApplicationError, with: :render_application_error
        rescue_from CurrencyNotSupportedError, with: :render_application_error
        rescue_from ExchangeRateUnavailableError, with: :render_application_error
        rescue_from RateLimitExceededError, with: :render_rate_limit_error
      end

      private

      def render_error(message, status, code = nil)
        render json: {
          error: {
            message: message,
            code: code || status.to_s,
            status: Rack::Utils.status_code(status),
          },
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

      def render_application_error(exception)
        Rails.logger.error("ApplicationError: #{exception.class.name} - #{exception.message}")
        Rails.logger.error(exception.backtrace.join("\n")) if Rails.env.development?

        render json: {
          error: exception.to_h,
        }, status: exception.http_status
      end

      def render_rate_limit_error(exception)
        response.set_header('Retry-After', exception.retry_after.to_s) if exception.retry_after
        render_application_error(exception)
      end

      def render_internal_error(exception)
        Rails.logger.error("Unhandled exception: #{exception.class.name} - #{exception.message}")
        Rails.logger.error(exception.backtrace.first(10).join("\n"))

        render_error(
          'An unexpected error occurred. Please try again later.',
          :internal_server_error,
          'INTERNAL_ERROR',
        )
      end
    end
  end
end
