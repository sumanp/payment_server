defmodule PaymentServerWeb.Types.User do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "User"
  object :user do
    field :id, non_null(:id)
    field :name, :string
    field :email, :string
  end
end
