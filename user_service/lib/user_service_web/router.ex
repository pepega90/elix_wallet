defmodule UserServiceWeb.Router do
  use UserServiceWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", UserServiceWeb do
    pipe_through(:api)

    resources("/users", UserController, except: [:new, :edit])
    post("/topup", UserController, :topup)
    post("/transfer", UserController, :transfer)
  end
end
