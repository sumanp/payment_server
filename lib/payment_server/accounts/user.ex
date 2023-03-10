defmodule PaymentServer.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias EctoShorts.CommonChanges
  alias PaymentServer.Repo

  schema "users" do
    field :email, :string
    field :name, :string

    has_many :wallets, PaymentServer.Accounts.Wallet
  end

  @available_params [:name, :email]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @available_params)
    |> validate_required(@available_params)
  end
end
