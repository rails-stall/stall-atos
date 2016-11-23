  # Atos payment gateway configuration
  # Fill in the informations provided by your bank (Atos service provider)
  #
  config.payment.atos do |atos|
    # Hmac key calculated with the js calculator given by CIC
    atos.merchant_id = ENV['ATOS_MERCHANT_ID']
    # Hmac key calculated with the js calculator given by CIC
    atos.secret_key = ENV['ATOS_SECRET_KEY']

    # Secret key version. Defaults to 1 when first generated, but you can update
    # this value if you generated another key
    #
    # atos.key_version = '1'

    # Test payment URL, provided by the bank
    atos.test_payment_url = ''
    # Production payment URL, provided by the bank
    atos.payment_url = ''

    # Atos / SIPS target version. Defaults to HP_2.9, but could need to be
    # updated, depending on the bank provided version
    #
    # atos.interface_version = 'HP_2.9'

    # Test or production mode, default to false, changes the payment
    # gateway target URL
    #
    # By default, the test mode is activated in all environments but you just
    # need to add `ATOS_PRODUCTION_MODE=true` in your environment variables
    # and restart your server to switch to production mode
    #
    atos.test_mode = ENV['ATOS_PRODUCTION_MODE'] != 'true'
  end

