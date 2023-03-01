defmodule PaymentServerWeb.Types.Wallet do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "Wallet"
  object :wallet do
    field :id, :id
    field :address, :string
  end
end
