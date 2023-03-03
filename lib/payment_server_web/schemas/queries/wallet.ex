defmodule PaymentServerWeb.Schemas.Queries.Wallet do
  use Absinthe.Schema.Notation
  alias PaymentServerWeb.Resolvers

  object :wallet_queries do
    field :wallet, :wallet do
      arg :user_id, non_null(:id)
      arg :currency, :string

      resolve(&Resolvers.Wallet.find/2)
    end

    field :wallets, list_of(:wallet) do
      arg :before, :integer
      arg :after, :integer
      arg :first, :integer

      resolve(&Resolvers.Wallet.all/2)
    end
  end
end
