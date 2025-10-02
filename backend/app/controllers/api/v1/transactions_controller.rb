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
      # Creates a new currency conversion transaction
      # Params: from_currency, to_currency, from_value
      def create
        service = Transactions::Create.new(user: current_user)
        
        transaction = service.call(
          from_currency: params[:from_currency],
          to_currency: params[:to_currency],
          from_value: params[:from_value]
        )

        if transaction
          render json: {
            transaction: transaction.as_json(
              only: [:id, :from_currency, :to_currency, :from_value, :to_value, :rate, :timestamp]
            ),
            message: 'Transaction created successfully'
          }, status: :created
        else
          render json: {
            errors: service.errors
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
