defmodule PaymentServer.ExchangeRate do
  alias PaymentServer.Accounts
  alias PaymentServer.ExchangeHelper

  @server_name ExchangeRateMonitor

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(supported_currencies, opts \\ []) do
    currency_pair =
      supported_currencies
      |> ExchangeHelper.all_currency_pair()
      |> ExchangeHelper.reject_twin_pair()
      |> ExchangeHelper.pair_keys()

    state = Enum.into(currency_pair, %{}, &{&1, "0.00"})
    opts = Keyword.put_new(opts, :name, @server_name)

    GenServer.start_link(ExchangeRate.Server, state, opts)
  end

  def broadcast_total_worth(%{user_id: user_id} = event, server \\ @server_name) do
    wallets = Accounts.list_wallets(%{user_id: user_id})
    params = Map.put(event, :wallets, wallets)
    GenServer.cast(server, {:broadcast_total_worth, params})
  end
end
