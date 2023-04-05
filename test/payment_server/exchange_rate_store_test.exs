defmodule PaymentServer.ExchangeRateStoreTest do
  use ExUnit.Case, async: true

  setup do
    supported_currencies = Application.fetch_env!(:payment_server, :supported_currencies)
    {:ok, pid} = PaymentServer.ExchangeRateStore.start_link(supported_currencies, name: nil)
    %{pid: pid}
  end

  describe "&get_exchange_rates/1" do
    test "returns exchange rates", %{pid: pid} do
      assert true === Process.alive?(pid)

      initial_fx_rates = %{
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

      assert initial_fx_rates === PaymentServer.ExchangeRateStore.get_exchange_rates(pid)
    end
  end

  describe "&update_rates/2" do
    test "updates exchange rates", %{pid: pid} do
      updated_fx_rates = %{
        EUR_GBP: "1.00",
        EUR_INR: "2.10",
        EUR_USD: "0.30",
        GBP_EUR: "0.50",
        GBP_INR: "2.00",
        GBP_USD: "3.00",
        INR_EUR: "5.01",
        INR_GBP: "3.03",
        INR_USD: "3.30",
        USD_EUR: "5.40",
        USD_GBP: "2.20",
        USD_INR: "1.10"
      }

      assert :ok === PaymentServer.ExchangeRateStore.update_rates(pid, updated_fx_rates)
      assert updated_fx_rates === PaymentServer.ExchangeRateStore.get_exchange_rates(pid)
    end
  end
end
