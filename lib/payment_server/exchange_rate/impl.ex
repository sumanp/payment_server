defmodule PaymentServer.ExchangeRate.Impl do
  require Logger

  def poll_exchange_rate(exchange_rate) do
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

  # Private / Utility functions

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
