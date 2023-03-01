defmodule PaymentServerWeb.Resolvers.User do
  def all(params, _), do: {:ok, []}

  def find(%{id: id}, _) do
    %{id: 1, name: "test", email: "test@test.com"}
  end
end
