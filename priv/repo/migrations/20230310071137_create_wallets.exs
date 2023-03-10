defmodule PaymentServer.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :address, :string
      add :currency, :string
      add :amount, :integer
      add(:user_id, references(:users, on_delete: :delete_all))
    end

    create(index(:wallets, [:user_id]))
  end
end
