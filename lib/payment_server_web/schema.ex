defmodule PaymentServerWeb.Schema do
  use Absinthe.Schema

  import_types(PaymentServerWeb.Types.User)
  import_types(PaymentServerWeb.Schemas.Queries.User)
  import_types(PaymentServerWeb.Schemas.Mutations.User)

  query do
    import_fields(:user_queries)
  end

  mutation do
    import_fields(:user_mutations)
  end

  # def context(ctx) do
  #   source = Dataloader.Ecto.new(PaymentServer.Repo)
  #   dataloader = Dataloader.add_source(Dataloader.new(), PaymentServer.Accounts, source)

  #   Map.put(ctx, :loader, dataloader)
  # end
end
