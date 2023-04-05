defmodule PaymentServer.ExchangeHelper do
  def all_currency_pair(currency_list) do
    Enum.flat_map(currency_list, fn x ->
      Enum.map(currency_list, fn y ->
        [x, y]
      end)
    end)
  end

  def reject_twin_pair(pair_list) do
    Enum.reject(pair_list, fn x ->
      List.first(x) === List.last(x)
    end)
  end

  def pair_keys(pair_list) do
    Enum.map(pair_list, fn x ->
      String.to_atom("#{List.first(x)}_#{List.last(x)}")
    end)
  end
end
