# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication' do
  let(:user_params) do
    {
      user: {
        email: 'test@example.com',
        password: 'password123',
      },
    }
  end

  describe 'POST /api/v1/auth (sign up)' do
    it 'creates a new user' do
      expect {
        post '/api/v1/auth', params: user_params, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)

      json = response.parsed_body
      expect(json['data']['email']).to eq('test@example.com')
      expect(json['status']['message']).to eq('Signed up successfully')
    end

    it 'returns 422 with invalid email' do
      invalid_params = { user: { email: 'invalid_email', password: 'password123' } }
      post '/api/v1/auth', params: invalid_params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 when email already exists' do
      create(:user, email: 'test@example.com')
      post '/api/v1/auth', params: user_params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST /api/v1/auth/sign_in' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    it 'returns JWT token with valid credentials' do
      post '/api/v1/auth/sign_in', params: user_params, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.headers['Authorization']).to match(/^Bearer .+/)

      json = response.parsed_body
      expect(json['message']).to eq('Signed in successfully')
      expect(json['user']['email']).to eq('test@example.com')
    end

    it 'token can be used for authenticated requests' do
      post '/api/v1/auth/sign_in', params: user_params, as: :json
      token = response.headers['Authorization']

      get '/api/v1/transactions', headers: { 'Authorization' => token, 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:ok)
    end

    it 'returns 401 with invalid credentials' do
      wrong_params = { user: { email: 'test@example.com', password: 'wrongpassword' } }
      post '/api/v1/auth/sign_in', params: wrong_params, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers['Authorization']).to be_nil
    end
  end

  describe 'DELETE /api/v1/auth/sign_out' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }
    let(:auth_token) do
      post '/api/v1/auth/sign_in', params: user_params, as: :json
      response.headers['Authorization']
    end

    it 'revokes the token' do
      delete '/api/v1/auth/sign_out', headers: { 'Authorization' => auth_token }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      # Message varies based on whether current_user is found
      expect(json['message']).to match(/Signed out/)

      # Token should not work after logout
      get '/api/v1/transactions', headers: { 'Authorization' => auth_token, 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'handles logout without token gracefully' do
      delete '/api/v1/auth/sign_out'

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['message']).to eq('Signed out')
    end
  end

  describe 'Full authentication flow' do
    it 'completes signup -> login -> access -> logout cycle' do
      flow_params = {
        user: {
          email: 'flowtest@example.com',
          password: 'password123',
        },
      }

      # Sign up
      post '/api/v1/auth', params: flow_params, as: :json
      expect(response).to have_http_status(:created)

      # Login to get token
      post '/api/v1/auth/sign_in', params: flow_params, as: :json
      expect(response).to have_http_status(:ok)
      token = response.headers['Authorization']

      # Access protected resource
      get '/api/v1/transactions', headers: { 'Authorization' => token, 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:ok)

      # Logout
      delete '/api/v1/auth/sign_out', headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)

      # Token should be revoked
      get '/api/v1/transactions', headers: { 'Authorization' => token, 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)

      # Login again with new token (JWT has different jti)
      post '/api/v1/auth/sign_in', params: flow_params, as: :json
      expect(response).to have_http_status(:ok)
      new_token = response.headers['Authorization']
      expect(new_token).to be_present
      expect(new_token).not_to eq(token) # Should be a different token

      get '/api/v1/transactions', headers: { 'Authorization' => new_token, 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:ok)
    end

    it 'prevents access without authentication' do
      get '/api/v1/transactions'
      expect(response).to have_http_status(:unauthorized)

      post '/api/v1/transactions', params: { from_currency: 'USD', to_currency: 'BRL', from_value: 100 }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
