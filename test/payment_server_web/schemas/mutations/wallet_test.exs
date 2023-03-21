defmodule PaymentServerWeb.Schemas.Mutations.WalletTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema
  alias PaymentServer.Accounts

  @create_wallet_doc """
  mutation CreateWallet($currency: String!, $address: String!, $amount: String!, $user_id: Int!) {
    createWallet(currency: $currency, address: $address, amount: $amount, user_id: $user_id) {
      id
      currency
      amount
      address
      user_id
    }
  }
  """
  describe "@createWallet" do
    test "creates wallet with params" do
      assert {:ok, user} =
               Accounts.create_user(%{
                 name: "name 1",
                 email: "name1@email.com"
               })

      create_currency = "USD"
      create_amount = "100.00"
      create_address = "asd@asd.com"

      assert {:ok, %{data: data}} =
               Absinthe.run(@create_wallet_doc, Schema,
                 variables: %{
                   "currency" => create_currency,
                   "amount" => create_amount,
                   "address" => create_address,
                   "user_id" => user.id
                 }
               )

      created_wallet_res = data["createWallet"]

      assert created_wallet_res["currency"] === create_currency
      assert created_wallet_res["amount"] === create_amount
      assert created_wallet_res["address"] === create_address

      money_type = Money.new(10_000)

      assert %{
               currency: ^create_currency,
               amount: ^money_type,
               address: ^create_address
             } = Accounts.find_wallet_by_currency(%{user_id: user.id, currency: create_currency})
    end
  end
end
