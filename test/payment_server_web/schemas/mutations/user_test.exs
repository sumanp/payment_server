defmodule PaymentServerWeb.Schemas.Mutations.UserTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema
  alias PaymentServer.Accounts

  @send_money_doc """
  mutation SendMoney($currency: String!, $amount: String!, $from_user_id: ID!, $to_user_id: ID!) {
    sendMoney(currency: $currency, amount: $amount, from_user_id: $from_user_id, to_user_id: $to_user_id) {
      status
      message
    }
  }
  """

  describe "@sendMoney" do
    test "sends money to another users wallet" do
      assert {:ok, user_1} =
               Accounts.create_user(%{
                 name: "name 1",
                 email: "name1@email.com"
               })

      assert {:ok, user_2} =
               Accounts.create_user(%{
                 name: "name 2",
                 email: "name2@email.com"
               })

      assert {:ok, _wallet_1} =
               Accounts.create_wallet(%{
                 currency: "USD",
                 address: "name1@email.com",
                 amount: "10",
                 user_id: user_1.id
               })

      assert {:ok, _wallet_2} =
               Accounts.create_wallet(%{
                 currency: "USD",
                 address: "name2@email.com",
                 amount: "10",
                 user_id: user_2.id
               })

      assert {:ok, %{data: data}} =
               Absinthe.run(@send_money_doc, Schema,
                 variables: %{
                   "currency" => "USD",
                   "amount" => "10",
                   "from_user_id" => user_1.id,
                   "to_user_id" => user_2.id
                 }
               )

      assert data["sendMoney"]["status"] === "SUCCESS"
      assert data["sendMoney"]["message"] === "Payment sent successfully"

      updated_amount = Money.new(2000)

      assert %{
               amount: ^updated_amount
             } = Accounts.find_wallet_by_currency(%{user_id: user_2.id, currency: "USD"})
    end
  end

  @create_user_doc """
  mutation CreateUser($name: String, $email: String) {
    createUser(name: $name, email: $email) {
      id
      name
      email
    }
  }
  """
  describe "@createUser" do
    test "creates user with params" do
      create_name = "Name"
      create_email = "test@test.com"

      assert {:ok, %{data: data}} =
               Absinthe.run(@create_user_doc, Schema,
                 variables: %{
                   "name" => create_name,
                   "email" => create_email
                 }
               )

      created_user_res = data["createUser"]

      assert created_user_res["name"] === create_name
      assert created_user_res["email"] === create_email

      assert {:ok,
              %{
                name: ^create_name,
                email: ^create_email
              }} = Accounts.find_user(%{id: created_user_res["id"]})
    end
  end
end
