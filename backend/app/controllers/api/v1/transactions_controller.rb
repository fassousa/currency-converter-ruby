# frozen_string_literal: true

module Api
  module V1
    class TransactionsController < BaseController
      # GET /api/v1/transactions
      # Returns transactions for the authenticated user with pagination
      # Params: page (default: 1), per_page (default: 20, max: 100)
      def index
        transactions = current_user.transactions
                                   .order(timestamp: :desc)
                                   .page(params[:page] || 1)
                                   .per(per_page_param)

        render json: {
          transactions: TransactionSerializer.collection(transactions),
          meta: pagination_meta(transactions),
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
          from_value: params[:from_value],
        )

        render json: {
          transaction: TransactionSerializer.new(transaction).as_json,
          message: 'Transaction created successfully',
        }, status: :created
      end

      private

      def per_page_param
        per_page = params[:per_page].to_i
        per_page = 20 if per_page <= 0
        per_page = 100 if per_page > 100
        per_page
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
        }
      end
    end
  end
end
