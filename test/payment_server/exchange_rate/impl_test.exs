defmodule PaymentServer.ExchangeRate.ImplTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.ExchangeRate.Impl
  alias PaymentServer.Accounts

  describe "&poll_exchange_rate/1" do
    test "updates exchange rate" do
      new_exchange_rate = Impl.poll_exchange_rate(initial_exchange_rate())

      assert [
               EUR_GBP: _,
               EUR_INR: _,
               EUR_USD: _,
               GBP_EUR: _,
               GBP_INR: _,
               GBP_USD: _,
               INR_EUR: _,
               INR_GBP: _,
               INR_USD: _,
               USD_EUR: _,
               USD_GBP: _,
               USD_INR: _
       ] = new_exchange_rate

      refute new_exchange_rate === initial_exchange_rate()
    end
  end

  defp initial_exchange_rate do
    %{
      EUR_GBP: "0.00",
      EUR_INR: "0.00",
      EUR_USD: "0.00",
      GBP_EUR: "0.00",
      GBP_INR: "0.00",
      GBP_USD: "0.00",
      INR_EUR: "0.00",
      INR_GBP: "0.00",
      INR_USD: "0.00",
      USD_EUR: "0.00",
      USD_GBP: "0.00",
      USD_INR: "0.00"
    }
  end
end
