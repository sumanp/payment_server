defmodule PaymentServerWeb.Schemas.Subscriptions.User do
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    field :total_worth, :total_worth do
      arg :user_id, non_null(:id)

      config fn args, _info ->
        {:ok, topic: "total_worth:#{args.user_id}"}
      end
    end
  end
end
