module Spree
  module Flowlink
    class WebhookController < ActionController::Base
      # Applications can use error_notifier to forward errors to tools like
      # airbrake, honeybadger, rollbar, etc.
      # This should be an object that responds to `call` and accepts the
      # responder as an argument.
      class_attribute :error_notifier

      before_action :load_user
      before_action :save_request_data, :authorize
      rescue_from Exception, :with => :exception_handler

      def consume
        handler = Handler::Base.build_handler(@called_hook, @webhook_body)

        responder = handler.process

        render_responder(responder)
      end

      protected

      def authorize
        return true if authorized?
        return true if valid_whitelisted_ip?

        base_handler = Handler::Base.new(@webhook_body)
        responder = base_handler.response("Unauthorized! #{request.remote_ip}", 401)
        render_responder(responder)

        # unless request.headers['HTTP_X_HUB_TOKEN'] == Spree::Flowlink::Config[:connection_token]
        #   base_handler = Handler::Base.new(@webhook_body)
        #   responder = base_handler.response('Unauthorized!', 401)
        #   render_responder(responder)
        #   return false
        # end
      end

      def exception_handler(exception)
        base_handler = Handler::Base.new(@webhook_body)
        responder = base_handler.response(exception.message, 500, nil, exception)
        render_responder(responder)
        return false
      end

      def save_request_data
        @called_hook = params[:path]
        @webhook_body = request.body.read
      end

      def render_responder(responder)
        if responder.exception
          logger.error responder.exception
          logger.error responder.exception.backtrace.join("\n").to_s
          if error_notifier
            error_notifier.call(responder)
          end
        end
        if responder.code >= 400
          logger.info "responder_summary=#{responder.summary.inspect}"
        end
        render(
          json: ResponderSerializer.new(responder, root: false),
          status: responder.code
        )
      end

      private

      def authorized?
        return false unless @current_api_user

        if Spree::Ability.new(@current_api_user)&.can?(:update, Spree::Order)
          logger.info("Access granted via spree api key for user: #{@current_api_user.id}")
          return true
        end
        false
      end

      def valid_whitelisted_ip?
        if [
          "34.75.173.205",
          "35.185.53.27",
          "104.196.23.105",
          "34.75.84.217",
          "34.73.228.209",
          "34.74.29.249",
          "35.231.138.73",
          "35.237.162.192",
          "35.243.135.196"
        ].include?(request.remote_ip)
          logger.info("Access granted via whitelisted IP: #{request.remote_ip}")
          return true
        end
        false
      end

      def load_user
        @current_api_user ||= Spree.user_class.find_by(spree_api_key: api_key.to_s)
      end

      def api_key
        pattern = /^Bearer /
        header = request.headers['Authorization']
        header.sub(pattern, '') if header.present? && header.match(pattern)
      end
    end
  end
end
