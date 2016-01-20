require 'spree/core'

module Spree
  module Flowlink
  end
end

require 'spree/flowlink/client'
require 'spree/flowlink/engine'
require 'spree/flowlink/responder'

require 'spree/flowlink/handler/base'

require 'spree/flowlink/handler/product_handler_base'
require 'spree/flowlink/handler/add_product_handler'
require 'spree/flowlink/handler/update_product_handler'

require 'spree/flowlink/handler/order_handler_base'
require 'spree/flowlink/handler/add_order_handler'
require 'spree/flowlink/handler/update_order_handler'

require 'spree/flowlink/handler/set_inventory_handler'
require 'spree/flowlink/handler/set_price_handler'

require 'spree/flowlink/handler/add_shipment_handler'
require 'spree/flowlink/handler/update_shipment_handler'

require 'spree/flowlink/handler/customer_handler_base'
require 'spree/flowlink/handler/add_customer_handler'
require 'spree/flowlink/handler/update_customer_handler'