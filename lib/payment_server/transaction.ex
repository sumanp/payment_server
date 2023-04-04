defmodule PaymentServer.Transaction do
  alias PaymentServer.Accounts
  alias PaymentServer.Accounts.Wallet
  alias PaymentServer.Repo

  def pay(%{
        to_user_id: to_user_id,
        from_user_id: from_user_id,
        amount: amount,
        currency: currency
      }) do
    with {:ok, to_wallet} <-
           Accounts.find_wallet_by_currency(%{user_id: to_user_id, currency: currency}),
         {:ok, from_wallet} <-
           Accounts.find_wallet_by_currency(%{user_id: from_user_id, currency: currency}) do
      amount =
        amount
        |> Integer.parse()
        |> elem(0)

      # stored as cents, integer data type
      amount = Money.new(amount * 100)

      if amount <= from_wallet.amount do
        transfer_money(from_wallet, to_wallet, amount)
      else
        {:ok, %{status: "ERROR", message: "Insufficient funds"}}
      end
    else
      _err -> {:ok, %{status: "ERROR", message: "Account not found"}}
    end
  end

  def transfer_money(from, to, amount) do
    # Use Ecto.Multi
    Wallet.transfer_money(from, to, amount)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        {:ok, %{status: "SUCCESS", message: "Payment sent successfully"}}

      {:error, _name, _value, _changes_so_far} ->
        {:ok, %{status: "ERROR", message: "Payment Unsuccessful"}}
    end
  end
end
