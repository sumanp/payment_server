defmodule PaymentServer.Accounts.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :address, :string
    field :currency, :string
    field :amount, Money.Ecto.Amount.Type

    timestamps()
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:address, :currency, :amount])
    |> validate_required([:address, :currency, :amount])
  end
end
