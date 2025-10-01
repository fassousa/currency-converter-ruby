module Authenticatable
  extend ActiveSupport::Concern

  included do
    # Use Devise helper to require authentication for controllers that include this concern
    before_action :authenticate_user!
  end

  private

  # Wrapper to render a JSON 401 when there's no signed-in user
  def ensure_authenticated!
    return if user_signed_in?
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
