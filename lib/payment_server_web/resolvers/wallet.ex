defmodule PaymentServerWeb.Resolvers.Wallet do
  alias PaymentServer.Accounts
  alias PaymentServer.Accounts.Wallet

  def all(params, _) do
    wallets =
      PaymentServer.Accounts.list_wallets(params)
      |> Enum.map(fn x ->
        %Wallet{x | amount: Money.to_string(x.amount)}
      end)

    {:ok, wallets}
  end

  def update(%{id: id} = params, _) do
    Accounts.update_wallet(id, params)
  end

  def create(params, _) do
    Accounts.create_wallet(params)
  end

  def total_worth(params, _) do
    {:ok, %{currency: "USD", value: 45}}
  end
end
