ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(PaymentServer.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:credo)
