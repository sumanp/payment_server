defmodule ExchangeRate.ImplTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.ExchangeRate.Impl
  alias PaymentServer.Accounts

  describe "&tick/1" do
    test "updates exchange rate" do
      assert %{exchange_rate: exchange_rate, timer: _timer} = Impl.tick(initial_exchange_rate())
      refute exchange_rate === initial_exchange_rate()
    end
  end

  describe "&broadcast_total_worth_info/2" do
    test "broadcasts total worth" do
      assert {:ok, user} =
               Accounts.create_user(%{
                 name: "name 1",
                 email: "name1@email.com"
               })

      assert {:ok, wallet} =
               Accounts.create_wallet(%{
                 currency: "INR",
                 address: "name1@email.com",
                 amount: "10",
                 user_id: user.id
               })

      event = %{currency: "USD", user_id: user.id, wallets: [wallet]}

      assert %{exchange_rate: exchange_rate, timer: _timer} =
               Impl.broadcast_total_worth_info(event, initial_exchange_rate())

      refute exchange_rate === initial_exchange_rate()
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
