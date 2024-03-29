defmodule PaymentServerWeb.Schema do
  use Absinthe.Schema

  import_types PaymentServerWeb.Types.User
  import_types PaymentServerWeb.Types.Wallet
  import_types PaymentServerWeb.Schemas.Queries.User
  import_types PaymentServerWeb.Schemas.Queries.Wallet
  import_types PaymentServerWeb.Schemas.Mutations.User
  import_types PaymentServerWeb.Schemas.Mutations.Wallet
  import_types PaymentServerWeb.Schemas.Subscriptions.User
  import_types PaymentServerWeb.Schemas.Subscriptions.Wallet

  query do
    import_fields :user_queries
    import_fields :wallet_queries
  end

  mutation do
    import_fields :user_mutations
    import_fields :wallet_mutations
  end

  subscription do
    import_fields :user_subscriptions
    import_fields :wallet_subscriptions
  end

  # def context(ctx) do
  #   source = Dataloader.Ecto.new(PaymentServer.Repo)
  #   dataloader = Dataloader.add_source(Dataloader.new(), PaymentServer.Accounts, source)

  #   Map.put(ctx, :loader, dataloader)
  # end
end
