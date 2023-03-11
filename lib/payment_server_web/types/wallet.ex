defmodule PaymentServerWeb.Types.Wallet do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "Wallet"
  object :wallet do
    field :id, non_null(:id)
    field :address, :string
    field :currency, :string
    field :amount, :string
    field :user_id, :integer
  end

  object :total_worth do
    field :currency, :string
    field :amount, :string
  end
end
