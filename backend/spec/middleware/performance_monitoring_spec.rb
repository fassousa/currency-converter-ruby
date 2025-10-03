# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PerformanceMonitoring do
  let(:app) { ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }
  let(:middleware) { described_class.new(app) }
  let(:env) { { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/api/v1/transactions', 'QUERY_STRING' => '', 'rack.input' => StringIO.new } }

  it 'passes request through and logs API endpoints' do
    allow(Rails.logger).to receive(:info)
    status, headers, response = middleware.call(env)

    expect([status, headers, response]).to eq([200, { 'Content-Type' => 'text/plain' }, ['OK']])
    expect(Rails.logger).to have_received(:info) do |msg|
      json = JSON.parse(msg)
      expect(json).to include('event' => 'performance_monitoring', 'method' => 'GET', 'path' => '/api/v1/transactions', 'status' => 200)
      expect(json['duration_ms']).to be_a(Numeric)
    end
  end

  it 'logs slow requests as warnings' do
    allow(Rails.logger).to receive(:warn)
    slow_app = lambda { |_env|
      sleep(1.1)
      [200, {}, ['OK']]
    }
    described_class.new(slow_app).call(env.merge('PATH_INFO' => '/slow'))

    expect(Rails.logger).to have_received(:warn) do |msg|
      expect(JSON.parse(msg)).to include('slow_request' => true)
    end
  end

  it 'skips logging for non-API fast requests' do
    allow(Rails.logger).to receive(:info)
    middleware.call(env.merge('PATH_INFO' => '/health'))
    expect(Rails.logger).not_to have_received(:info)
  end
end
