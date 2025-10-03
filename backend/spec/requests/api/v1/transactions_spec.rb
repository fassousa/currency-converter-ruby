require 'rails_helper'

RSpec.describe 'Api::V1::Transactions', type: :request do
  let(:user) { create(:user) }
  let(:auth_token) do
    post '/api/v1/auth/sign_in', params: { user: { email: user.email, password: user.password } }, as: :json
    response.headers['Authorization']
  end
  let(:auth_headers) { { 'Authorization' => auth_token } }
  let(:json_response) { JSON.parse(response.body) }
  let(:expected_fields) { %w[id from_currency to_currency from_value to_value rate timestamp] }

  before do
    stub_request(:get, /api.currencyapi.com/).to_return(
      status: 200,
      body: { data: { 'BRL' => { code: 'BRL', value: 5.25 } } }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  describe 'GET /api/v1/transactions' do
    context 'when authenticated' do
      before do
        create_list(:transaction, 5, user: user)
        create_list(:transaction, 3, user: create(:user))
      end

      it 'returns user transactions with correct count and fields' do
        get '/api/v1/transactions', headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(json_response['transactions'].size).to eq(5)
        expect(json_response['meta']['total_count']).to eq(5)
        expect(json_response['transactions'].first.keys).to match_array(expected_fields)
      end

      it 'returns transactions ordered by timestamp descending' do
        get '/api/v1/transactions', headers: auth_headers

        timestamps = json_response['transactions'].map { |t| Time.parse(t['timestamp']) }
        expect(timestamps).to eq(timestamps.sort.reverse)
      end

      it 'paginates results with 20 per page by default' do
        create_list(:transaction, 30, user: user)
        get '/api/v1/transactions', headers: auth_headers

        expect(json_response['transactions'].size).to eq(20)
        expect(json_response['meta']['total_count']).to eq(35)
        expect(json_response['meta']['total_pages']).to eq(2)
      end

      it 'respects custom per_page parameter up to 100' do
        create_list(:transaction, 120, user: user)
        get '/api/v1/transactions', params: { per_page: 50 }, headers: auth_headers

        expect(json_response['transactions'].size).to eq(50)
      end

      it 'enforces maximum limit of 100 per page' do
        create_list(:transaction, 120, user: user)
        get '/api/v1/transactions', params: { per_page: 200 }, headers: auth_headers
        
        expect(json_response['transactions'].size).to eq(100)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        get '/api/v1/transactions'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/transactions' do
    let(:valid_params) { { from_currency: 'USD', to_currency: 'BRL', from_value: '100.00' } }

    context 'when authenticated' do
      context 'with valid parameters' do
        it 'creates transaction and returns it with success message' do
          expect {
            post '/api/v1/transactions', params: valid_params, headers: auth_headers
          }.to change(Transaction, :count).by(1)

          expect(response).to have_http_status(:created)
          expect(json_response['transaction']['from_currency']).to eq('USD')
          expect(json_response['transaction']['to_currency']).to eq('BRL')
          expect(json_response['message']).to eq('Transaction created successfully')
          expect(json_response['transaction'].keys).to match_array(expected_fields)
          expect(Transaction.last.user).to eq(user)
        end
      end

      context 'with invalid parameters' do
        shared_examples 'rejects invalid params' do |params_change|
          it "rejects #{params_change.keys.first}" do
            invalid_params = params_change[:merge] ? valid_params.merge(params_change[:merge]) : valid_params.except(*params_change[:except])
            
            expect {
              post '/api/v1/transactions', params: invalid_params, headers: auth_headers
            }.not_to change(Transaction, :count)
            
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response['errors']).to be_present
          end
        end

        include_examples 'rejects invalid params', except: [:from_currency]
        include_examples 'rejects invalid params', except: [:to_currency]
        include_examples 'rejects invalid params', except: [:from_value]
        include_examples 'rejects invalid params', merge: { from_value: '-100.00' }
        include_examples 'rejects invalid params', merge: { from_value: '0' }
        include_examples 'rejects invalid params', merge: { from_currency: 'INVALID' }
      end

      context 'when API fails' do
        before { stub_request(:get, /api.currencyapi.com/).to_return(status: 500) }

        it 'returns error and does not create transaction' do
          expect {
            post '/api/v1/transactions', params: valid_params, headers: auth_headers
          }.not_to change(Transaction, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to be_present
        end
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized and does not create transaction' do
        expect {
          post '/api/v1/transactions', params: valid_params
        }.not_to change(Transaction, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
