defmodule AHappyBotWeb.Router do
  use AHappyBotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AHappyBotWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AHappyBotWeb do
    pipe_through :browser

    get "/", PageController, :index
    live "/live", StreamLive, :index
  end
end
