defmodule PaymentServerWeb.Resolvers.User do
  def all(params, _), do: {:ok, []}

  def create(params, _) do
    {:ok, []}
  end

  def find(params, _) do
    {:ok, %{}}
  end
end
