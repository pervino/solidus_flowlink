require 'active_model_serializers'

module Spree
  module Flowlink
    class ReimbursementSerializer < ActiveModel::Serializer
      attributes :id, :order_id, :total, :paid_amount, :reimbursement_status, :refunds
      has_many :return_items, serializer: Spree::Flowlink::ReturnItemSerializer
      has_many :refunds, serializer: Spree::Flowlink::RefundSerializer

      def id
        object.number
      end

      def order_id
        object.order.try(:number)
      end
    end
  end
end
