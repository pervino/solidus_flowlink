require 'active_model_serializers'

module Spree
  module Flowlink
    class PromotionCodeSerializer < ActiveModel::Serializer
      attributes :value
    end
  end
end
