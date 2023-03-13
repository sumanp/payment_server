defmodule PaymentServerWeb.Schemas.Mutations.User do
  use Absinthe.Schema.Notation
  alias PaymentServerWeb.Resolvers

  object :user_mutations do
    field :create_user, :user do
      arg :name, :string
      arg :email, :string

      resolve &Resolvers.User.create/2
    end

    field :send_money, :transaction do
      arg :to_user_id, non_null(:id)
      arg :from_user_id, non_null(:id)
      arg :currency, :string
      arg :amount, :string

      resolve &Resolvers.User.send_money/2
    end
  end
end
