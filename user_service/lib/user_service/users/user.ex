defmodule UserService.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name]}

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:password, :string)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
    |> hash_password()
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      hashed_password = :crypto.hash(:sha256, password) |> Base.encode16()
      change(changeset, %{password: hashed_password})
    else
      changeset
    end
  end
end
