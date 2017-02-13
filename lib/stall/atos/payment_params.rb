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
        @data ||= self.class.serialize(
          amount: cart.total_price.cents.to_i,
          currencyCode: cart.currency.iso_numeric,
          orderId: cart.reference,
          merchantId: gateway.merchant_id,
          transactionReference: gateway.transaction_id(refresh: true),
          keyVersion: gateway.key_version,
          automaticResponseUrl: gateway.payment_urls.payment_notification_url,
          normalReturnUrl: gateway.payment_urls.payment_success_return_url
        )
      end

      def seal
        @seal ||= self.class.calculate_seal_for(data)
      end

      private

      # Transforms the provided hash to the following Atos accepted format :
      #
      #   key1=value1|key2=value2|...|keyN=valueN
      #
      def self.serialize(hash)
        hash.map { |item| item.map(&:to_s).join('=') }.join('|')
      end

      def self.unserialize(string)
        string.split('|').each_with_object({}.with_indifferent_access) do |str, hash|
          key, value = str.split('=')
          hash[key] = value
        end
      end

      def self.calculate_seal_for(data)
        Digest::SHA256.hexdigest([data, Stall::Atos::Gateway.secret_key].join)
      end
    end
  end
end
