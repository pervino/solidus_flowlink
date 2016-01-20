module Spree
  class FlowlinkConfiguration < Preferences::Configuration
    preference :batch_size, :integer, default: 10
    preference :connection_id, :string
    preference :connection_token, :string
    preference :push_url, :string, :default => 'https://push.flowlink.io'
    preference :push_objects, :array, :default => ["Spree::Order", "Spree::Product"]
    preference :payload_builder, :hash, :default => {
        "Spree::Order" => {:serializer => "Spree::Flowlink::OrderSerializer", :root => "orders", :filter => "complete"},
        "Spree::Product" => {:serializer => "Spree::Flowlink::ProductSerializer", :root => "products"},
    }
    preference :last_pushed_timestamps, :hash, :default => {
        "Spree::Order" => nil,
        "Spree::Product" => nil
    }
  end
end
