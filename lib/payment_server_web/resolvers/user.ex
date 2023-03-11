defmodule PaymentServerWeb.Resolvers.User do
  alias PaymentServer.Accounts

  def all(params, _), do: {:ok, Accounts.list_users(params)}

  def update(%{id: id} = params, _) do
    Accounts.update_user(id, params)
  end

  def create(params, _) do
    Accounts.create_user(params)
  end
end
