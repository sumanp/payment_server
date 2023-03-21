defmodule PaymentServer.ExchangeRate do
  use GenServer

  require Logger
  alias PaymentServer.Worth
  alias PaymentServer.Accounts

  @refresh_interval_ms 1_000
  @server_name PaymentServer

  # Client
  def start_link(supported_currencies, opts \\ []) do
    currency_pair =
      supported_currencies
      |> all_currency_pair()
      |> reject_twin_pair()
      |> pair_keys()

    state = Enum.into(currency_pair, %{}, &{&1, "0.00"})
    opts = Keyword.put_new(opts, :name, @server_name)

    GenServer.start_link(PaymentServer.ExchangeRate, state, opts)
  end

  def get_exchange_rate(currency_pair, server \\ @server_name) do
    GenServer.call(server, {:get_exchange_rate, currency_pair})
  end

  def get_exchange_rates(server \\ @server_name) do
    GenServer.call(server, {:get_exchange_rates})
  end

  def broadcast_total_worth(%{user_id: user_id} = event, server \\ @server_name) do
    wallets = Accounts.list_wallets(%{user_id: user_id})
    params = Map.put(event, :wallets, wallets)
    GenServer.cast(server, {:broadcast_total_worth, params})
  end

  # Server Callbacks
  @impl true
  def init(state) do
    Process.flag(:trap_exit, true)
    timer = Process.send_after(self(), :tick, @refresh_interval_ms)

    {:ok, %{exchange_rate: state, timer: timer}}
  end

  @impl true
  def handle_call({:get_exchange_rate, currency_pair}, _from_pid, state) do
    {:reply, state[:exchange_rate][currency_pair], state}
  end

  @impl true
  def handle_call({:get_exchange_rates}, _from_pid, state) do
    {:reply, state[:exchange_rate], state}
  end

  @impl true
  def handle_cast(
        {:broadcast_total_worth, event},
        %{exchange_rate: exchange_rate, timer: timer} = _state
      ) do
    Process.cancel_timer(timer)
    new_exchange_rate = do_refresh(exchange_rate)

    amount =
      Money.to_string(Worth.calculate_total(event.currency, event.wallets, new_exchange_rate))

    Absinthe.Subscription.publish(
      PaymentServerWeb.Endpoint,
      %{
        currency: event.currency,
        amount: amount
      },
      total_worth: "total_worth:#{event.user_id}"
    )

    new_timer = Process.send_after(self(), {:broadcast_total_worth, event}, @refresh_interval_ms)

    {:noreply, %{exchange_rate: new_exchange_rate, timer: new_timer}}
  end

  @impl true
  def handle_info(:tick, %{exchange_rate: exchange_rate} = _state) do
    new_exchange_rate = do_refresh(exchange_rate)
    timer = Process.send_after(self(), :tick, @refresh_interval_ms)

    {:noreply, %{exchange_rate: new_exchange_rate, timer: timer}}
  end

  @impl true
  def handle_info({:broadcast_total_worth, event}, %{exchange_rate: exchange_rate} = _state) do
    new_exchange_rate = do_refresh(exchange_rate)

    amount =
      Money.to_string(Worth.calculate_total(event.currency, event.wallets, new_exchange_rate))

    Absinthe.Subscription.publish(
      PaymentServerWeb.Endpoint,
      %{
        currency: event.currency,
        amount: amount
      },
      total_worth: "total_worth:#{event.user_id}"
    )

    timer = Process.send_after(self(), {:broadcast_total_worth, event}, @refresh_interval_ms)

    {:noreply, %{exchange_rate: new_exchange_rate, timer: timer}}
  end

  # Private/utility methods

  defp all_currency_pair(currency_list) do
    Enum.flat_map(currency_list, fn x ->
      Enum.map(currency_list, fn y ->
        [x, y]
      end)
    end)
  end

  defp reject_twin_pair(pair_list) do
    Enum.reject(pair_list, fn x ->
      List.first(x) === List.last(x)
    end)
  end

  defp pair_keys(pair_list) do
    Enum.map(pair_list, fn x ->
      String.to_atom("#{List.first(x)}_#{List.last(x)}")
    end)
  end

  defp do_refresh(exchange_rate) do
    urls = map_request_urls(exchange_rate)

    result =
      urls
      |> Task.async_stream(&HTTPoison.get/1)
      |> Enum.map(fn {:ok, {:ok, result}} ->
        res = Jason.decode!(result.body)
        from = res["Realtime Currency Exchange Rate"]["1. From_Currency Code"]
        to = res["Realtime Currency Exchange Rate"]["3. To_Currency Code"]
        key = String.to_atom(from <> "_" <> to)
        value = res["Realtime Currency Exchange Rate"]["5. Exchange Rate"]

        Absinthe.Subscription.publish(
          PaymentServerWeb.Endpoint,
          %{
            from: from,
            to: to,
            amount: value
          },
          exchange_rates: "exchange_rates:*"
        )

        Absinthe.Subscription.publish(
          PaymentServerWeb.Endpoint,
          %{
            from: from,
            to: to,
            amount: value
          },
          exchange_rates_by_currency: "exchange_rates:#{to}"
        )

        {key, value}
      end)

    result
  end

  defp map_request_urls(exchange_rate) do
    Enum.map(exchange_rate, fn {k, _v} ->
      code = String.split(Atom.to_string(k), "_")

      "http://localhost:4001/query?function=CURRENCY_EXCHANGE_RATE&from_currency=#{List.first(code)}&to_currency=#{List.last(code)}&apikey=demo"
    end)
  end
end
