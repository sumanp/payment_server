import Config

config :payment_server,
  supported_currencies: [
    "USD",
    "INR",
    "EUR",
    "GBP"
  ]

config :money,
  default_currency: :USD,
  symbol: false
