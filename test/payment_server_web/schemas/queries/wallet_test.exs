defmodule PaymentServerWeb.Schemas.Queries.WalletTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema
  alias PaymentServer.Accounts

  @all_wallet_doc """
  query AllWallet($first: Int, $after: Int, $before: Int) {
    wallets(first: $first, after: $after, before: $before) {
      id
      currency
      amount
      user_id
    }
  }
  """

  describe "@wallets" do
    test "fetch first x wallets" do
      assert {:ok, user} =
               Accounts.create_user(%{
                 name: "name 1",
                 email: "name1@email.com"
               })

      assert {:ok, wallet_1} =
               Accounts.create_wallet(%{
                 currency: "USD",
                 address: "name1@email.com",
                 amount: "10",
                 user_id: user.id
               })

      assert {:ok, wallet_2} =
               Accounts.create_wallet(%{
                 currency: "USD",
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

      assert {:ok, %{data: data}} =
               Absinthe.run(@all_wallet_doc, Schema,
                 variables: %{
                   "first" => 2
                 }
               )

      assert length(data["wallets"]) === 2
      assert List.first(data["wallets"])["id"] === to_string(wallet_1.id)
      assert List.last(data["wallets"])["id"] === to_string(wallet_2.id)
    end

    test "fetch wallets after x" do
      assert {:ok, user} =
               Accounts.create_user(%{
                 name: "name 1",
                 email: "name1@email.com"
               })

      assert {:ok, wallet_1} =
               Accounts.create_wallet(%{
                 currency: "USD",
                 address: "name1@email.com",
                 amount: "10",
                 user_id: user.id
               })

      assert {:ok, wallet_2} =
               Accounts.create_wallet(%{
                 currency: "USD",
                 address: "name2@email.com",
                 amount: "10",
                 user_id: user.id
               })

      assert {:ok, wallet_3} =
               Accounts.create_wallet(%{
                 currency: "USD",
                 address: "name3@email.com",
                 amount: "10",
                 user_id: user.id
               })

      assert {:ok, %{data: data}} =
               Absinthe.run(@all_wallet_doc, Schema,
                 variables: %{
                   "after" => wallet_1.id
                 }
               )

      assert length(data["wallets"]) === 2
      assert List.first(data["wallets"])["id"] === to_string(wallet_2.id)
      assert List.last(data["wallets"])["id"] === to_string(wallet_3.id)
    end

    test "fetch wallets before x" do
      assert {:ok, user} =
               Accounts.create_user(%{
                 name: "name 1",
                 email: "name1@email.com"
               })

      assert {:ok, wallet_1} =
               Accounts.create_wallet(%{
                 currency: "USD",
                 address: "name1@email.com",
                 amount: "10",
                 user_id: user.id
               })

      assert {:ok, wallet_2} =
               Accounts.create_wallet(%{
                 currency: "USD",
                 address: "name2@email.com",
                 amount: "10",
                 user_id: user.id
               })

      assert {:ok, wallet_3} =
               Accounts.create_wallet(%{
                 currency: "USD",
                 address: "name3@email.com",
                 amount: "10",
                 user_id: user.id
               })

      assert {:ok, %{data: data}} =
               Absinthe.run(@all_wallet_doc, Schema,
                 variables: %{
                   "before" => wallet_3.id
                 }
               )

      assert length(data["wallets"]) === 2
      assert List.first(data["wallets"])["id"] === to_string(wallet_1.id)
      assert List.last(data["wallets"])["id"] === to_string(wallet_2.id)
    end
  end
end
