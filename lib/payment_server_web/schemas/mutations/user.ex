defmodule PaymentServerWeb.Schemas.Mutations.User do
  use Absinthe.Schema.Notation
  alias PaymentServerWeb.Resolvers

  object :user_mutations do
    field :create_user, :user do
      arg(:name, :string)
      arg(:email, :string)

      resolve(&Resolvers.User.create/2)
    end
  end
end
