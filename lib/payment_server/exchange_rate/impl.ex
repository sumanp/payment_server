defmodule PaymentServer.ExchangeRate.Impl do
  alias PaymentServer.Worth
  alias PaymentServer.ExchangeRateStore
  require Logger

  @refresh_interval_ms 1_000
  @server_name ExchangeRateMonitor

  def broadcast_total_worth(event, exchange_rate, timer) do
    Process.cancel_timer(timer)
    new_exchange_rate = poll_exchange_rate(exchange_rate)

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

    new_timer =
      Process.send_after(@server_name, {:broadcast_total_worth, event}, @refresh_interval_ms)

    %{exchange_rate: new_exchange_rate, timer: new_timer}
  end

  def tick(exchange_rate) do
    new_exchange_rate = poll_exchange_rate(exchange_rate)
    ExchangeRateStore.update_rates(new_exchange_rate)
    timer = Process.send_after(self(), :tick, @refresh_interval_ms)

    %{exchange_rate: new_exchange_rate, timer: timer}
  end

  def broadcast_total_worth_info(event, exchange_rate) do
    new_exchange_rate = poll_exchange_rate(exchange_rate)

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

    %{exchange_rate: new_exchange_rate, timer: timer}
  end

  # Private / Utility functions

  defp poll_exchange_rate(exchange_rate) do
    urls = map_request_urls(exchange_rate)

    urls
    |> Task.async_stream(&HTTPoison.get/1)
    |> Enum.map(fn
      {:ok, {:ok, result}} ->
        res = Jason.decode!(result.body)
        from = res["Realtime Currency Exchange Rate"]["1. From_Currency Code"]
        to = res["Realtime Currency Exchange Rate"]["3. To_Currency Code"]
        key = String.to_atom(from <> "_" <> to)
        value = res["Realtime Currency Exchange Rate"]["5. Exchange Rate"]

        publish_all_exchange_rates(from, to, value)
        publish_each_exchange_rates(from, to, value)

        {key, value}

      {:ok, {:error, %HTTPoison.Error{reason: reason}}} ->
        Logger.warning(reason)
        {:error, 0}
    end)
  end

  defp map_request_urls(exchange_rate) do
    Enum.map(exchange_rate, fn {k, _v} ->
      code = String.split(Atom.to_string(k), "_")

      "http://localhost:4001/query?function=CURRENCY_EXCHANGE_RATE&from_currency=#{List.first(code)}&to_currency=#{List.last(code)}&apikey=demo"
    end)
  end

  defp publish_all_exchange_rates(from, to, value) do
    Absinthe.Subscription.publish(
      PaymentServerWeb.Endpoint,
      %{
        from: from,
        to: to,
        amount: value
      },
      exchange_rates: "exchange_rates:*"
    )
  end

  defp publish_each_exchange_rates(from, to, value) do
    Absinthe.Subscription.publish(
      PaymentServerWeb.Endpoint,
      %{
        from: from,
        to: to,
        amount: value
      },
      exchange_rates_by_currency: "exchange_rates:#{to}"
    )
  end
end
