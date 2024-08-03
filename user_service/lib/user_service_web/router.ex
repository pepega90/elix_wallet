defmodule UserServiceWeb.Router do
  use UserServiceWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :auth do
    plug(Guardian.Plug.Pipeline,
      module: UserService.Guardian,
      error_handler: UserService.AuthErrorHandler
    )

    plug(Guardian.Plug.VerifyHeader)
    plug(Guardian.Plug.LoadResource)
  end

  scope "/api", UserServiceWeb do
    pipe_through([:api])
    post("/users", UserController, :create)
    post("/login", UserController, :login)
  end

  scope "/api", UserServiceWeb do
    pipe_through([:api, :auth])
    get("/users/:id", UserController, :show)
    post("/topup", UserController, :topup)
    post("/transfer", UserController, :transfer)
  end
end
