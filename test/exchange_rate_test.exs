defmodule ExchangeRateTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.Accounts

  setup do
    supported_currencies = Application.fetch_env!(:payment_server, :supported_currencies)
    {:ok, pid} = PaymentServer.ExchangeRate.start_link(supported_currencies, name: nil)
    %{pid: pid}
  end

  describe "&broadcast_total_worth/2" do
    test "returns :ok on cast", %{pid: pid} do
      assert {:ok, user} =
               Accounts.create_user(%{
                 name: "name 1",
                 email: "name1@email.com"
               })

      assert {:ok, _} =
               Accounts.create_wallet(%{
                 currency: "USD",
                 address: "name1@email.com",
                 amount: "10",
                 user_id: user.id
               })

      assert true === Process.alive?(pid)

      assert :ok ===
               PaymentServer.ExchangeRate.broadcast_total_worth(
                 %{user_id: user.id, currency: "USD"},
                 pid
               )
    end
  end
end
