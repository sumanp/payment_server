defmodule PaymentServerWeb.Schemas.Queries.UserTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema
  alias PaymentServer.Accounts

  @all_user_doc """
  query AllUser($first: Int, $after: Int, $before: Int) {
    users(first: $first, after: $after, before: $before) {
      id
      name
      email
    }
  }
  """

  describe "@users" do
    test "fetch first x users" do
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

      assert {:ok, _} =
               Accounts.create_user(%{
                 name: "name 3",
                 email: "name3@email.com"
               })

      assert {:ok, %{data: data}} =
               Absinthe.run(@all_user_doc, Schema,
                 variables: %{
                   "first" => 2
                 }
               )

      assert length(data["users"]) === 2
      assert List.first(data["users"])["id"] === to_string(user_1.id)
      assert List.last(data["users"])["id"] === to_string(user_2.id)
    end

    test "fetch users after x" do
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

      assert {:ok, user_3} =
               Accounts.create_user(%{
                 name: "name 3",
                 email: "name3@email.com"
               })

      assert {:ok, %{data: data}} =
               Absinthe.run(@all_user_doc, Schema,
                 variables: %{
                   "after" => user_1.id
                 }
               )

      assert length(data["users"]) === 2
      assert List.first(data["users"])["id"] === to_string(user_2.id)
      assert List.last(data["users"])["id"] === to_string(user_3.id)
    end

    test "fetch users before x" do
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

      assert {:ok, user_3} =
               Accounts.create_user(%{
                 name: "name 3",
                 email: "name3@email.com"
               })

      assert {:ok, %{data: data}} =
               Absinthe.run(@all_user_doc, Schema,
                 variables: %{
                   "before" => user_3.id
                 }
               )

      assert length(data["users"]) === 2
      assert List.first(data["users"])["id"] === to_string(user_1.id)
      assert List.last(data["users"])["id"] === to_string(user_2.id)
    end
  end
end
