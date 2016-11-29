# Stall::Atos

This gem allows integrating your [Stall](https://github.com/stall-rails/stall)
e-commerce app with one of the Atos online payment gateway solutions.

This gem is just the glue between [Stall](https://github.com/stall-rails/stall)
and the provided Atos executable.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stall-atos'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stall-atos

Then use the install generator to copy the config template file :

    $ rails generator stall:atos:install


## Usage

You first need to configure the gateway by filling the required variables in
that were added to the stall config initialize.

By default, it is configured to fetch from the variables from the environment,
so ideally, just create the following env vars :

- `ATOS_MERCHANT_ID`
- `ATOS_SECRET_KEY`

> **Note** : Test merchant id and secret key can be different than production
ones.

Now, go to the Stall initializer, and fill in the test and production URLs
provdided by your bank in the `atos.test_payment_url` and `atos.payment_url`
configuration.

Restart your server, and you should now be able to use the CM-CIC payment
gateway in test mode.

When you're ready to switch to production, set the following environment
variable :

- `ATOS_PRODUCTION_MODE=true`

Just like the other settings, you can change the way it's configured in the
stall initializer file.

### Automatic response URL

You need to provide a payment response URL to your bank which will be :

```text
<http|http>://<YOUR_DOMAIN>/atos/payment/notify
```

You can find the route with :

```bash
rake routes | grep payment/notify
```

### Faking a payment notification

From your console :

```ruby
# Fetch the cart you want to simulate a payment notification for
cart = Cart.last
# Create the fake notification request
request = Stall::Atos::FakeGatewayPaymentNotification.new(cart)
# Pass it to the PaymentNotificationService, where the simulation will take place
Stall::PaymentNotificationService.new('atos', request).call
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stall-rails/stall-atos.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

