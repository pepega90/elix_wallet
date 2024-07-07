defmodule UserService.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name]}

  schema "users" do
    field(:name, :string)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
