require 'json'

module Spree
  module Flowlink
    module Handler
      class Base

        attr_accessor :payload, :parameters, :request_id

        def initialize(message)
          self.payload = ::JSON.parse(message).with_indifferent_access
          self.request_id = payload.delete(:request_id)

          if payload.key? :parameters
            if payload[:parameters].is_a? Hash
              self.parameters = payload.delete(:parameters).with_indifferent_access
            end
          end
          self.parameters ||= {}

        end

        def self.build_handler(path, message)
          klass = ("Spree::Flowlink::Handler::" + path.camelize + "Handler").constantize
          klass.new(message)
        end

        def response(message, code = 200, objects = nil, exception = nil)
          Spree::Flowlink::Responder.new(@request_id, message, code, objects, exception)
        end

        def self.flowlink_objects_for(object)

          flowlink_objects_hash = {}
          class_name = object.class.name
          case class_name
            when "Spree::Order"
              if Spree::Flowlink::Config[:payload_builder]["Spree::Order"]
                payload_builder = Spree::Flowlink::Config[:payload_builder]["Spree::Order"]
                flowlink_objects_hash[payload_builder[:root]] = generate_order_payload(object.reload)
                if Spree::Flowlink::Config[:push_objects].include? "Spree::Shipment"
                  payload_builder = Spree::Flowlink::Config[:payload_builder]["Spree::Shipment"]
                  flowlink_objects_hash[payload_builder[:root]] = generate_shipments_payload(object.reload.shipments)
                end
              end
            when "Spree::Shipment"
              if Spree::Flowlink::Config[:payload_builder]["Spree::Shipment"]
                payload_builder = Spree::Flowlink::Config[:payload_builder]["Spree::Shipment"]
                flowlink_objects_hash[payload_builder[:root]] = generate_shipments_payload(object.order.reload.shipments)
                if Spree::Flowlink::Config[:push_objects].include? "Spree::Order"
                  payload_builder = Spree::Flowlink::Config[:payload_builder]["Spree::Order"]
                  flowlink_objects_hash[payload_builder[:root]] = generate_order_payload(object.order.reload)
                end
              end
          end
          flowlink_objects_hash
        end

        def process
          raise "Please implement the process method in your handler"
        end

        private

        def self.generate_shipments_payload(shipments)
          payload_builder = Spree::Flowlink::Config[:payload_builder]["Spree::Shipment"]
          shipments_payload = []
          shipments.each do |shipment|
            shipments_payload << JSON.parse(payload_builder[:serializer].constantize.new(shipment, root: false).to_json)
          end
          shipments_payload
        end

        def self.generate_order_payload(order)
          payload_builder = Spree::Flowlink::Config[:payload_builder]["Spree::Order"]
          order_payload = []
          order_payload << JSON.parse(payload_builder[:serializer].constantize.new(order, root: false).to_json)
        end

      end
    end
  end
end
