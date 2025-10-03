# frozen_string_literal: true

module Api
  module V1
    module Paginatable
      extend ActiveSupport::Concern

      private

      def per_page_param
        per_page = params[:per_page].to_i
        return 20 if per_page <= 0
        return 100 if per_page > 100

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
