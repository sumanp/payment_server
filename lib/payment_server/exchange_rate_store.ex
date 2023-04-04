defmodule PaymentServer.ExchangeRateStore do
  use Agent

  alias PaymentServer.FxHelper

  @default_name ExchangeRateStore

  def start_link(supported_currencies, opts \\ []) do
    currency_pair =
      supported_currencies
      |> FxHelper.all_currency_pair()
      |> FxHelper.reject_twin_pair()
      |> FxHelper.pair_keys()

    initial_state = Enum.into(currency_pair, %{}, &{&1, "0.00"})
    opts = Keyword.put_new(opts, :name, @default_name)

    Agent.start_link(fn -> initial_state end, opts)
  end

  def update_rates(server \\ @default_name, rates) do
    Agent.update(server, fn _state ->
      rates
    end)
  end

  def get_exchange_rates(server \\ @default_name) do
    Agent.get(server, fn state ->
      state
    end)
  end
end
