defmodule PaymentServerWeb.Resolvers.User do
  alias PaymentServer.Accounts
  alias PaymentServer.Transaction

  def all(params, _), do: {:ok, Accounts.list_users(params)}

  def update(%{id: id} = params, _) do
    Accounts.update_user(id, params)
  end

  def create(params, _) do
    Accounts.create_user(params)
  end

  # use with statement
  def send_money(params, _) do
    Transaction.pay(params)
  end
end
