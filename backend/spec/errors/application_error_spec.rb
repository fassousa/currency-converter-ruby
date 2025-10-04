# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationError do
  describe '#initialize' do
    it 'uses defaults and accepts custom values' do # rubocop:disable RSpec/MultipleExpectations
      error = described_class.new
      expect(error.message).to eq('An error occurred')
      expect(error.status).to eq(:internal_server_error)
      expect(error.error_code).to eq('application_error')
      expect(error.details).to eq({})

      custom = described_class.new('Custom', status: :bad_request, error_code: 'custom', details: { key: 'val' })
      expect(custom.message).to eq('Custom')
      expect(custom.status).to eq(:bad_request)
      expect(custom.error_code).to eq('custom')
      expect(custom.details).to eq({ key: 'val' })
    end
  end

  describe '#to_h' do
    it 'returns hash with error data' do
      hash = described_class.new('Test', status: :bad_request, error_code: 'test', details: { foo: 'bar' }).to_h
      expect(hash[:error]).to include(type: 'test', message: 'Test', details: { foo: 'bar' })
    end
  end

  describe '#http_status' do
    it 'returns the status' do
      expect(described_class.new(status: :not_found).http_status).to eq(:not_found)
    end
  end
end
