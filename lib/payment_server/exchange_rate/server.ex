defmodule PaymentServer.ExchangeRate.Server do
  use GenServer

  alias PaymentServer.ExchangeRate.Impl
  alias PaymentServer.Worth
  alias PaymentServer.ExchangeRateStore


  @refresh_interval_ms 1_000
  @server_name ExchangeRateMonitor

  @impl true
  def init(state) do
    Process.flag(:trap_exit, true)
    timer = Process.send_after(self(), :tick, @refresh_interval_ms)

    {:ok, %{exchange_rate: state, timer: timer}}
  end

  @impl true
  def handle_cast(
        {:broadcast_total_worth, event},
        %{exchange_rate: exchange_rate, timer: timer} = _state
      ) do
    Process.cancel_timer(timer)
    new_exchange_rate = Impl.poll_exchange_rate(exchange_rate)
    publish_total_worth(event, new_exchange_rate)

    new_timer =
      Process.send_after(@server_name, {:broadcast_total_worth, event}, @refresh_interval_ms)

    {:noreply, %{exchange_rate: new_exchange_rate, timer: new_timer}}
  end

  @impl true
  def handle_info(:tick, %{exchange_rate: exchange_rate} = _state) do
    new_exchange_rate = Impl.poll_exchange_rate(exchange_rate)
    ExchangeRateStore.update_rates(new_exchange_rate)
    timer = Process.send_after(self(), :tick, @refresh_interval_ms)

    {:noreply, %{exchange_rate: new_exchange_rate, timer: timer}}
  end

  @impl true
  def handle_info({:broadcast_total_worth, event}, %{exchange_rate: exchange_rate} = _state) do
    new_exchange_rate = Impl.poll_exchange_rate(exchange_rate)
    publish_total_worth(event, new_exchange_rate)

    timer = Process.send_after(self(), {:broadcast_total_worth, event}, @refresh_interval_ms)

    {:noreply, %{exchange_rate: new_exchange_rate, timer: timer}}
  end

  defp publish_total_worth(event, new_exchange_rate) do
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
  end
end
