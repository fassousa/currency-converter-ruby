# frozen_string_literal: true

module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        render json: { message: 'Signed in successfully', user: { id: resource.id, email: resource.email } },
               status: :ok
      end

      def respond_to_on_destroy
        # `current_user` may be nil if the token is invalid/expired — Devise will handle that.
        if current_user
          sign_out(current_user)
          render json: { message: 'Signed out successfully' }, status: :ok
        else
          render json: { message: 'Signed out' }, status: :ok
        end
      end
    end
  end
end
