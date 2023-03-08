import Config

config :payment_server,
  supported_currencies: [
    "USD",
    "INR",
    "EUR",
    "GBP"
  ]

# Application.fetch_env!(:payment_server, :supported_currencies)
