require 'digest'

module Stall
  module Atos
    class PaymentParams
      attr_reader :gateway

      delegate :cart, :target_url, :interface_version, to: :gateway

      def initialize(gateway)
        @gateway = gateway
      end

      def data
        @data ||= serialize(
          amount: cart.total_price.cents,
          currencyCode: cart.currency.iso_numeric,
          merchantId: gateway.merchant_id,
          transactionReference: gateway.transaction_id(refresh: true),
          keyVersion: gateway.key_version,

          automaticResponseUrl: gateway.payment_urls.payment_notification_url,
          normalReturnUrl: gateway.payment_urls.payment_success_return_url
        )
      end

      def seal
        @seal ||= Digest::SHA256.hexdigest([data, gateway.secret_key].join)
      end

      private

      # Transforms the provided hash to the following Atos accepted format :
      #
      #   key1=value1|key2=value2|...|keyN=valueN
      #
      def serialize(hash)
        hash.map { |item| item.map(&:to_s).join('=') }.join('|')
      end
    end
  end
end
