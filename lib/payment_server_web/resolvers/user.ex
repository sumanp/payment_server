defmodule PaymentServerWeb.Resolvers.User do
  alias PaymentServer.Accounts

  def all(params, _), do: {:ok, Accounts.list_users(params)}

  def update(%{id: id} = params, _) do
    Accounts.update_user(id, params)
  end

  def create(params, _) do
    Accounts.create_user(params)
  end

  # use with statement
  def send_money(
        %{to_user_id: to_user_id, from_user_id: from_user_id, amount: amount, currency: currency} =
          _params,
        _
      ) do
    with to_wallet <-
           Accounts.find_wallet_by_currency(%{user_id: to_user_id, currency: currency}),
         from_wallet <-
           Accounts.find_wallet_by_currency(%{user_id: from_user_id, currency: currency}) do
      amount =
        amount
        |> Integer.parse()
        |> elem(0)

      # stored as cents, integer data type
      amount = Money.new(amount * 100)

      if(amount <= from_wallet.amount) do
        add_amount = Money.add(to_wallet.amount, amount)
        subtract_amount = Money.subtract(from_wallet.amount, amount)

        Accounts.update_wallet(to_wallet.id, %{amount: add_amount})
        Accounts.update_wallet(from_wallet.id, %{amount: subtract_amount})
        {:ok, %{status: "SUCCESS", message: "Payment sent successfully"}}
      else
        {:ok, %{status: "ERROR", message: "Insufficient funds"}}
      end
    else
      _err -> {:ok, %{status: "ERROR", message: "Account not found"}}
    end
  end
end
