defmodule PaymentServerWeb.Types.User do
  use Absinthe.Schema.Notation

  @desc "User"
  object :user do
    field :id, non_null(:id)
    field :name, :string
    field :email, :string
  end

  object :transaction do
    field :status, :string
    field :message, :string
  end
end
