# frozen_string_literal: true

module Api
  module V1
    # Concern for logging API requests and responses
    module RequestLogging
      extend ActiveSupport::Concern

      included do
        before_action :log_request
        after_action :log_response
      end

      private

      def log_request
        @request_started_at = Time.current
        Rails.logger.info({
          event: 'api_request',
          method: request.method,
          path: request.fullpath,
          controller: controller_name,
          action: action_name,
          params: filtered_params,
          user_id: current_user&.id,
          request_id: request.uuid,
          remote_ip: request.remote_ip,
          user_agent: request.user_agent,
        }.to_json)
      end

      def log_response
        Rails.logger.info({
          event: 'api_response',
          method: request.method,
          path: request.fullpath,
          controller: controller_name,
          action: action_name,
          status: response.status,
          user_id: current_user&.id,
          request_id: request.uuid,
          duration_ms: calculate_duration,
        }.to_json)
      end

      def filtered_params
        params.except(:controller, :action, :format, :password, :password_confirmation).to_unsafe_h
      end

      def calculate_duration
        return unless @request_started_at

        ((Time.current - @request_started_at) * 1000).round(2)
      end
    end
  end
end
