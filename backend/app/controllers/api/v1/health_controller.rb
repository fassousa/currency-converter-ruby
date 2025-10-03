# frozen_string_literal: true

module Api
  module V1
    # Health check endpoint for monitoring
    class HealthController < BaseController
      skip_before_action :authenticate_user!, only: [:show]

      # GET /api/v1/health
      def show
        health_status = {
          status: 'healthy',
          timestamp: Time.current.iso8601,
          version: Rails.application.config.version || '1.0.0',
          environment: Rails.env,
          services: check_services,
        }

        render json: health_status, status: :ok
      rescue StandardError => e
        render json: {
          status: 'unhealthy',
          timestamp: Time.current.iso8601,
          error: e.message,
        }, status: :service_unavailable
      end

      private

      def check_services
        {
          database: check_database,
          cache: check_cache,
          external_api: check_external_api,
        }
      end

      def check_database
        ActiveRecord::Base.connection.execute('SELECT 1')
        { status: 'up', message: 'Database is accessible' }
      rescue StandardError => e
        { status: 'down', message: e.message }
      end

      def check_cache
        Rails.cache.write('health_check', Time.current.to_i)
        Rails.cache.read('health_check')
        Rails.cache.delete('health_check')

        { status: 'up', message: 'Cache is accessible' }
      rescue StandardError => e
        { status: 'down', message: e.message }
      end

      def check_external_api
        # Don't make actual API calls in health check to avoid rate limits
        # Just verify configuration is present
        if ENV['CURRENCY_API_KEY'].present?
          { status: 'configured', message: 'API key is configured' }
        else
          { status: 'not_configured', message: 'API key is missing' }
        end
      end
    end
  end
end
