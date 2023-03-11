defmodule PaymentServerWeb.Resolvers.Wallet do
  alias PaymentServer.Accounts
  alias PaymentServer.Accounts.Wallet

  def all(params, _) do
    {:ok, PaymentServer.Accounts.list_wallets(params)}
  end

  def update(%{id: id} = params, _) do
    Accounts.update_wallet(id, params)
  end

  def find_by_currency(params, _) do
    {:ok, Accounts.find_wallet_by_currency(params)}
  end

  def create(params, _) do
    Accounts.create_wallet(params)
  end

  def total_worth(params, _) do
    {:ok, %{currency: "USD", value: 45}}
  end
end
