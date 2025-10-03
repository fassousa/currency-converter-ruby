# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health Check' do
  describe 'GET /api/v1/health' do
    it 'returns health status without authentication' do
      get '/api/v1/health'
      expect(response).to have_http_status(:ok)
      
      json = JSON.parse(response.body)
      expect(json).to include('status' => 'healthy', 'environment' => 'test')
      expect(json).to have_key('timestamp').and have_key('version')
      expect(json['services']).to include('database' => include('status' => 'up'), 
                                          'cache' => include('status' => 'up'),
                                          'external_api' => include('status'))
    end

    it 'reports service failures' do
      allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(StandardError.new('DB error'))
      get '/api/v1/health'
      expect(JSON.parse(response.body)['services']['database']).to include('status' => 'down', 'message' => 'DB error')

      allow(ActiveRecord::Base.connection).to receive(:execute).and_call_original
      allow(Rails.cache).to receive(:write).and_raise(StandardError.new('Cache error'))
      get '/api/v1/health'
      expect(JSON.parse(response.body)['services']['cache']).to include('status' => 'down', 'message' => 'Cache error')
    end
  end
end
