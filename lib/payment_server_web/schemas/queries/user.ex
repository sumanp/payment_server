defmodule PaymentServerWeb.Schemas.Queries.User do
  use Absinthe.Schema.Notation
  alias PaymentServerWeb.Resolvers

  object :user_queries do
    field :user, :user do
      arg :currency, :string

      resolve(&Resolvers.User.find/2)
    end

    field :users, list_of(:user) do
      arg :before, :integer
      arg :after, :integer
      arg :first, :integer

      resolve(&Resolvers.User.all/2)
    end
  end
end
