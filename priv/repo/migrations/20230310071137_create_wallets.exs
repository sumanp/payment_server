defmodule PaymentServer.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :address, :string
      add :currency, :string
      add :amount, :integer

      timestamps()
    end
  end
end
