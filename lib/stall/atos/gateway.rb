module Stall
  module Atos
    class Gateway < Stall::Payments::Gateway
      register :atos

      # Merchant ID
      class_attribute :merchant_id
      # Secret key found in the banks's download interface
      class_attribute :secret_key
      # Secret key version
      class_attribute :key_version
      self.key_version = '1'

      # Test payment URL to send payment form to, provided by the bank
      class_attribute :test_payment_url
      # Production payment URL to send payment form to, provided by the bank
      class_attribute :payment_url

      # Interface version of the Atos / SIPS API
      class_attribute :interface_version
      self.interface_version = 'HP_2.9'

      # Test or production mode, default to false, changes the payment
      # gateway target URL
      class_attribute :test_mode
      self.test_mode = !Rails.env.production?

      def self.request(cart)
        Request.new(cart)
      end

      def self.response(request)
        Response.new(request)
      end

      def self.fake_payment_notification_for(cart)
        Stall::Atos::FakeGatewayPaymentNotification.new(cart)
      end

      def target_url
        test_mode ? test_payment_url : payment_url
      end

      private

      # Override the transaction id methods, since the Atos gateway only
      # authorize numbers
      def next_transaction_id
        if (last_transaction = Payment.order("data->>'transaction_id' DESC").select(:data).first)
          if (id = last_transaction.transaction_id)
            index = id[-5..-1].to_i + 1
            return transaction_id_for(index)
          end
        end

        transaction_id_for(1)
      end

      def transaction_id_for(index)
        super.gsub(/-/, '')
      end

      def transaction_id_format
        '%{cart_id}%{transaction_index}'
      end

      class Request
        attr_reader :cart

        delegate :currency, to: :cart, allow_nil: true

        def initialize(cart)
          @cart = cart
        end

        def payment_form_partial_path
          'stall/atos/payment_form'
        end

        def params
          @params ||= Stall::Atos::PaymentParams.new(gateway)
        end

        def gateway
          @gateway = Stall::Atos::Gateway.new(cart)
        end
      end

      class Response
        attr_reader :request

        def initialize(request)
          @request = request
        end

        def rendering_options
          { nothing: true }
        end

        def success?
          response.success?
        end

        def notify
          cart.payment.pay! if success?
        end

        def valid?
          response.valid?
        end

        def cart
          @cart ||= Cart.find_by_payment_transaction_id(response.transaction_id)
        end

        def gateway
          @gateway = Stall::Atos::Gateway
        end

        private

        def response
          @response ||= Stall::Atos::PaymentResponse.new(
            gateway, Rack::Utils.parse_nested_query(request.raw_post)
          )
        end
      end
    end
  end
end
