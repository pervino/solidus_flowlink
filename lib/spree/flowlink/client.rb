require 'json'
require 'openssl'
require 'httparty'
require 'active_model/array_serializer'

module Spree
  module Flowlink
    class Client

      def self.push_batches(object, ts_offset = 5)
        object_count = 0

        last_push_time = Spree::Flowlink::Config[:last_pushed_timestamps][object] || Time.at(0)
        this_push_time = Time.now

        payload_builder = Spree::Flowlink::Config[:payload_builder][object]

        model_name = payload_builder[:model].present? ? payload_builder[:model] : object

        scope = model_name.constantize

        if filter = payload_builder[:filter]
          scope = scope.send(filter.to_sym)
        end

        # go 'ts_offset' seconds back in time to catch missing objects
        last_push_time = last_push_time - ts_offset.seconds

        scope.where(updated_at: last_push_time...this_push_time).find_in_batches(batch_size: Spree::Flowlink::Config[:batch_size]) do |batch|
          object_count += batch.size
          payload = ActiveModel::ArraySerializer.new(
              batch,
              each_serializer: payload_builder[:serializer].constantize,
              root: payload_builder[:root]
          ).to_json

          push(payload) unless object_count == 0
        end

        update_last_pushed(object, this_push_time) unless object_count == 0
        object_count
      end
      
      def self.push_batches_until(object, minutes_since_last_push)
        object_count = 0

        last_push_time = Spree::Flowlink::Config[:last_pushed_timestamps][object] || Time.at(0)
        this_push_time = last_push_time + minutes_since_last_push.minutes

        payload_builder = Spree::Flowlink::Config[:payload_builder][object]

        model_name = payload_builder[:model].present? ? payload_builder[:model] : object

        scope = model_name.constantize

        if filter = payload_builder[:filter]
          scope = scope.send(filter.to_sym)
        end

        # go 'ts_offset' seconds back in time to catch missing objects
        last_push_time = last_push_time - 5

        scope.where(updated_at: last_push_time...this_push_time).find_in_batches(batch_size: Spree::Flowlink::Config[:batch_size]) do |batch|
          object_count += batch.size
          payload = ActiveModel::ArraySerializer.new(
              batch,
              each_serializer: payload_builder[:serializer].constantize,
              root: payload_builder[:root]
          ).to_json

          push(payload) unless object_count == 0
        end

        update_last_pushed(object, this_push_time) unless object_count == 0
        object_count
      end      

      def self.push(json_payload)
        begin
          req = {
              body: json_payload,
              headers: {
                  'Content-Type' => 'application/json',
                  'X-Hub-Store' => Spree::Flowlink::Config[:connection_id],
                  'X-Hub-Access-Token' => Spree::Flowlink::Config[:connection_token],
                  'X-Hub-Timestamp' => Time.now.utc.to_i.to_s
              }
          }

          res = HTTParty.post(
              Spree::Flowlink::Config[:push_url],
              req
          )

          raise PushApiError, "Push not successful. Flowlink returned response code #{res.code} and message: #{res.body}" if res.code != 202
        rescue PushApiError => exception
          Bugsnag.notify(exception) do |notification|
            notification.add_tab(:flowlink, {
                request: req,
                response: res
            })
          end
          raise exception
        end
      end

      private
      def self.update_last_pushed(object, new_last_pushed)
        last_pushed_ts = Spree::Flowlink::Config[:last_pushed_timestamps]
        last_pushed_ts[object] = new_last_pushed
        Spree::Flowlink::Config[:last_pushed_timestamps] = last_pushed_ts
      end

      def self.validate(res)
        raise PushApiError, "Push not successful. Flowlink returned response code #{res.code} and message: #{res.body}" if res.code != 202
      end
    end
  end
end

class PushApiError < StandardError;
end
