defmodule PaymentServerWeb.Schemas.Mutations.Wallet do
  use Absinthe.Schema.Notation
  alias PaymentServerWeb.Resolvers

  object :wallet_mutations do
    field :create_wallet, :wallet do
      arg :currency, :string
      arg :amount, :string
      arg :address, :string
      arg :user_id, :integer

      resolve(&Resolvers.Wallet.create/2)
    end
  end
end
