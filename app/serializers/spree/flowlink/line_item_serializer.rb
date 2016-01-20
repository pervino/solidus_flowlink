require 'active_model_serializers'

module Spree
  module Flowlink
    class LineItemSerializer < ActiveModel::Serializer
      attributes :id, :product_id, :name, :quantity, :price

      def product_id
        object.variant.sku
      end

      def price
        object.price.to_f
      end

    end
  end
end
