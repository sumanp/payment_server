defmodule PaymentServerWeb.Schemas.Subscriptions.Wallet do
  use Absinthe.Schema.Notation

  object :wallet_subscriptions do
    field :exchange_rates, :exchange_rates do
      config fn args, info ->
        {:ok, topic: "exchange_rates:*"}
      end
    end

    field :exchange_rates_by_currency, :exchange_rates do
      arg :currency, non_null(:string)

      config fn args, info ->
        {:ok, topic: "exchange_rates:#{args.currency}"}
      end
    end
  end
end
