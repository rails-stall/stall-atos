require 'stall'

module Stall
  module Atos
    extend ActiveSupport::Autoload

    autoload :PaymentParams
    autoload :Version

    autoload :FakeGatewayPaymentNotification
  end
end

require 'stall/atos/gateway'
require 'stall/atos/engine'
