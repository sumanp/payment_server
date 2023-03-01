defmodule PaymentServerWeb.Types.User do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "User with preferences"
  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
  end
end
