defmodule PaymentServer.Worth do
  alias PaymentServer.Accounts.Wallet
  alias PaymentServer.ExchangeRate

  def calculate_total(currency, wallets, exchange_rates) do
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
