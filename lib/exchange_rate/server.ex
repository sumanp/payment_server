defmodule ExchangeRate.Server do
  use GenServer

  alias ExchangeRate.Impl
  @refresh_interval_ms 1_000

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
    {:noreply, Impl.broadcast_total_worth(event, exchange_rate, timer)}
  end

  @impl true
  def handle_info(:tick, %{exchange_rate: exchange_rate} = _state) do
    {:noreply, Impl.tick(exchange_rate)}
  end

  @impl true
  def handle_info({:broadcast_total_worth, event}, %{exchange_rate: exchange_rate} = _state) do
    {:noreply, Impl.broadcast_total_worth_info(event, exchange_rate)}
  end
end
