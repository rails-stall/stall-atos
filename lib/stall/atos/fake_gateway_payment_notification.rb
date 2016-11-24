module Stall
  module Atos
    class FakeGatewayPaymentNotification < Stall::Payments::FakeGatewayPaymentNotification
      delegate :currency, to: :cart

      def params
        {}.tap do |params|
          params.merge!(options)
        end
      end

      private

      def options
        @options ||= {
          "Data" => data,
          "Seal" => Stall::Atos::PaymentParams.calculate_seal_for(data),
          "InterfaceVersion" => "HP_2.0",
          "Encode" => ""
        }
      end

      def data
        @data ||= Stall::Atos::PaymentParams.serialize(
          merchantId: gateway.merchant_id,
          transactionReference: gateway.transaction_id,
          keyVersion: gateway.key_version,
          amount: cart.total_price.cents,
          currencyCode: cart.currency.iso_numeric,
          transactionDateTime: Time.now.iso8601,
          captureDay: '0',
          captureMode: 'AUTHOR_CAPTURE',
          orderChannel: 'INTERNET',
          responseCode: '00',
          acquirerResponseCode: '00',
          authorisationId: '12345',
          guaranteeIndicator: 'N',
          cardCSCResultCode: '4E',
          panExpiryDate: '210001',
          paymentMeanBrand: 'VISA',
          paymentMeanType: 'CARD',
          customerIpAddress: '127.0.0.1',
          maskedPan: '4100##########00',
          holderAuthentRelegation: 'N',
          holderAuthentStatus: '3D_ERROR',
          transactionOrigin: 'INTERNET',
          paymentPattern: 'ONE_SHOT'
        )
      end
    end
  end
end
