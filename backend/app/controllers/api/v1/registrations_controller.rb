# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            status: { code: 201, message: 'Signed up successfully' },
            data: { id: resource.id, email: resource.email },
          }, status: :created
        else
          render json: {
            status: { code: 422, message: 'User could not be created' },
            errors: resource.errors.full_messages,
          }, status: :unprocessable_entity
        end
      end

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
