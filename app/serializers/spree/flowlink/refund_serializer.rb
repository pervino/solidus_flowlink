require 'active_model_serializers'

module Spree
  module Flowlink
    class RefundSerializer < ActiveModel::Serializer
      attributes :reason, :amount, :description
      has_one :payment, serializer: Spree::Flowlink::PaymentSerializer

      def reason
        object.reason.try(:name)
      end
    end
  end
end
