defmodule PaymentServer.Accounts.Wallet do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias PaymentServer.Accounts.Wallet

  schema "wallets" do
    field :address, :string
    field :currency, :string
    field :amount, Money.Ecto.Amount.Type

    belongs_to :user, PaymentServer.Accounts.User
  end

  @available_params [:address, :currency, :amount, :user_id]

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, @available_params)
    |> validate_required(@available_params)
  end

  def filter_by_currency(%{user_id: user_id, currency: currency} = _params) do
    from w in PaymentServer.Accounts.Wallet,
      where: w.currency == ^currency and w.user_id == ^user_id
  end

  def transfer_money(from, to, amount) do
    add_amount = Money.add(to.amount, amount)
    subtract_amount = Money.subtract(from.amount, amount)

    to_update =
      from Wallet,
        where: [id: ^to.id],
        update: [set: [amount: ^add_amount]]

    from_update =
      from Wallet,
        where: [id: ^from.id],
        update: [set: [amount: ^subtract_amount]]

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:to, to_update, [])
    |> Ecto.Multi.run(:check_to, fn
      _repo, %{to: {1, _}} -> {:ok, nil}
      _repo, %{to: {_, _}} -> {:error, {:failed_transfer, to}}
    end)
    |> Ecto.Multi.update_all(:from, from_update, [])
    |> Ecto.Multi.run(:check_from, fn
      _repo, %{from: {1, _}} -> {:ok, nil}
      _repo, %{from: {_, _}} -> {:error, {:failed_transfer, from}}
    end)
  end
end
