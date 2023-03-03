defmodule PaymentServerWeb.Resolvers.Wallet do
  def all(params, _), do: {:ok, []}

  def create(params, _) do
    {:ok, []}
  end

  def find(params, _) do
    {:ok, %{id: 1, address: "asdadas", currency: "USD", value: 45}}
  end
end
