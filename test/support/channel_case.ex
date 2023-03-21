defmodule PaymentServerWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest

      @endpoint PaymentServerWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(PaymentServer.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(PaymentServer.Repo, {:shared, self()})
    end

    :ok
  end
end
