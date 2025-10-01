module Api
  module V1
    class TransactionsController < BaseController
      # GET /api/v1/transactions
      # Returns transactions for the authenticated user
      def index
        transactions = current_user.transactions.order(timestamp: :desc).limit(100)
        
        render json: {
          transactions: transactions.as_json(
            only: [:id, :from_currency, :to_currency, :from_value, :to_value, :rate, :timestamp]
          ),
          count: transactions.count
        }, status: :ok
      end

      # POST /api/v1/transactions
      # Will be implemented in Phase 3 with currency conversion service
      def create
        render json: { 
          message: 'Transaction creation will be implemented in Phase 3' 
        }, status: :not_implemented
      end
    end
  end
end
