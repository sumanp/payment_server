defmodule PaymentServerWeb.Schemas.Subscriptions.Wallet do
  use Absinthe.Schema.Notation

  object :wallet_subscriptions do
    field :exchange_rates, :exchange_rates do
      config fn args, info ->
        {:ok, topic: "exchange_rates:*"}
      end
    end
  end
end
