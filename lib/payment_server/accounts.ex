defmodule PaymentServer.Accounts do
  alias PaymentServer.Accounts.{User, Wallet}
  alias EctoShorts.Actions

  def list_users(params \\ %{}) do
    Actions.all(User, params)
  end

  def find_user(params) do
    Actions.find(User, params)
  end

  def update_user(id, params) do
    Actions.update(User, id, params)
  end

  def create_user(params) do
    Actions.create(User, params)
  end

  def list_wallets(params \\ %{}) do
    Actions.all(Wallet, params)
  end

  def find_wallet_by_currency(params) do
    Actions.find(Wallet, params)
  end

  def update_wallet(id, params) do
    Actions.update(Wallet, id, params)
  end

  def create_wallet(params) do
    Actions.create(Wallet, params)
  end
end
