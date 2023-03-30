defmodule PaymentServer.ExchangeRateStore do
  use Agent

  @default_name ExchangeRateStore

  def start_link(supported_currencies, opts \\ []) do
    currency_pair =
      supported_currencies
      |> all_currency_pair()
      |> reject_twin_pair()
      |> pair_keys()

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
end
