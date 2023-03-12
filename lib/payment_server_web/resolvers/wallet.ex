defmodule PaymentServerWeb.Resolvers.Wallet do
  alias PaymentServer.Accounts
  alias PaymentServer.Accounts.Wallet
  alias PaymentServer.ExchangeRate

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

  def total_worth(%{currency: currency} = params, _) do
    {:ok, %{currency: currency, amount: calculate_total(params)}}
  end

  defp calculate_total(%{user_id: user_id, currency: currency} = _params) do
    exchange_rates = ExchangeRate.get_exchange_rates()
    wallets = Accounts.list_wallets(%{user_id: user_id})

    Enum.reduce(wallets, Money.new(0), fn wallet, acc ->
      if wallet.currency == currency do
        Money.add(acc, wallet.amount)
      else
        key = String.to_atom(wallet.currency <> "_" <> currency)

        fx_rate =
          exchange_rates[key]
          |> Float.parse()
          |> elem(0)

        Money.add(acc, Money.multiply(wallet.amount, fx_rate))
      end
    end)
  end
end
