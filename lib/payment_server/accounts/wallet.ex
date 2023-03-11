defmodule PaymentServer.Accounts.Wallet do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "wallets" do
    field :address, :string
    field :currency, :string
    field :amount, Money.Ecto.Amount.Type

    belongs_to :user, PaymentServer.Accounts.User
  end

  @available_params [:address, :currency, :amount]

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, @available_params)
    |> validate_required(@available_params)
  end
end