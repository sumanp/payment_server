defmodule PaymentServerWeb.Resolvers.Wallet do
  alias PaymentServer.Accounts
  alias PaymentServer.Worth
  alias PaymentServer.ExchangeRateStore

  def all(params, _) do
    {:ok, PaymentServer.Accounts.list_wallets(params)}
  end

  def update(%{id: id} = params, _) do
    Accounts.update_wallet(id, params)
  end

  def find_by_currency(params, _) do
    Accounts.find_wallet_by_currency(params)
  end

  def create(params, _) do
    Accounts.create_wallet(params)
  end

  def total_worth(%{currency: currency, user_id: user_id} = _params, _) do
    wallets = Accounts.list_wallets(%{user_id: user_id})
    fx_rates = ExchangeRateStore.get_exchange_rates()
    {:ok, %{currency: currency, amount: Worth.calculate_total(currency, wallets, fx_rates)}}
  end
end
