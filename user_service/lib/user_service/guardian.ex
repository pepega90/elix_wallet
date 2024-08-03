defmodule UserService.Guardian do
  use Guardian, otp_app: :user_service

  def subject_for_token(user, _claims) do
    # menggunakan id user sebagai subject JWT
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    # disini kita fetch user berdasarkan user id dari claims
    id = claims["sub"]
    resource = UserService.Users.get_user!(id)
    {:ok, resource}
  rescue
    _ -> {:error, :resource_not_found}
  end
end
