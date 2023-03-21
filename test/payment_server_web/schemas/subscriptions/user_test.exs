defmodule PaymentServerWeb.Schemas.Subscriptions.UserTest do
  use PaymentServer.SubscriptionCase
  import Ecto.Query

  alias PaymentServer.Accounts
  alias PaymentServer.Repo
  alias PaymentServer.ExchangeRate
  alias PaymentServer.Worth

  @total_woth_sub_doc """
  subscription TotalWorth($user_id: ID!, $currency: String!) {
    totalWorth(user_id: $user_id, currency: $currency) {
      amount
      currency
    }
  }
  """

  describe "@totalWorth" do
    test "receives users total_worth data when subscribed", %{socket: socket} do
      assert {:ok, user} =
               Accounts.create_user(%{
                 name: "name 1",
                 email: "name1@email.com"
               })

      assert {:ok, wallet_1} =
               Accounts.create_wallet(%{
                 currency: "EUR",
                 address: "name1@email.com",
                 amount: "10",
                 user_id: user.id
               })

      assert {:ok, wallet_2} =
               Accounts.create_wallet(%{
                 currency: "INR",
                 address: "name2@email.com",
                 amount: "10",
                 user_id: user.id
               })

      assert {:ok, _} =
               Accounts.create_wallet(%{
                 currency: "USD",
                 address: "name3@email.com",
                 amount: "10",
                 user_id: user.id
               })

      ref =
        push_doc(socket, @total_woth_sub_doc,
          variables: %{"user_id" => user.id, "currency" => "GBP"}
        )

      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      wallets = Accounts.list_wallets(%{user_id: user.id})
      fx_rates = ExchangeRate.get_exchange_rates()
      amount = Money.to_string(Worth.calculate_total("GBP", wallets, fx_rates))

      assert :ok =
               Absinthe.Subscription.publish(
                 PaymentServerWeb.Endpoint,
                 %{currency: "GBP", amount: amount},
                 total_worth: "total_worth:#{user.id}"
               )

      assert_push "subscription:data", data

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "totalWorth" => %{
                     "amount" => ^amount,
                     "currency" => "GBP"
                   }
                 }
               }
             } = data
    end
  end
end
