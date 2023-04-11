defmodule PaymentServerWeb.Schemas.Subscriptions.User do
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    field :total_worth, :total_worth do
      arg :user_id, non_null(:id)
      arg :currency, non_null(:string)

      config fn args, _info ->
        ExchangeRate.broadcast_total_worth(args)

        {:ok, topic: "total_worth:#{args.user_id}"}
      end

      resolve fn total_worth, _, _ ->
        {:ok, total_worth}
      end
    end
  end
end
