defmodule AHappyBot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # spotify_config = [
    #   client_id: Application.get_env(:a_happy_bot, :spotify_client_id),
    #   client_secret: Application.get_env(:a_happy_bot, :spotify_client_secret),
    #   refresh_token: Application.get_env(:a_happy_bot, :spotify_refresh_token)
    # ]

    # config = [
    #   user: Application.get_env(:a_happy_bot, :twitch_user),
    #   pass: Application.get_env(:a_happy_bot, :twitch_pass),
    #   chats: Application.get_env(:a_happy_bot, :twitch_chats),
    #   handler: AHappyBot.ChatHandler,
    #   capabilities: Application.get_env(:a_happy_bot, :capabilities)
    # ]

    children = [
      #{TMI.Supervisor, config},
      #{AHappyBot.Spotify, spotify_config},
      {Plug.Cowboy, scheme: :http, plug: Web.Router, options: [port: 8088]}
    ]

    opts = [strategy: :one_for_one, name: AHappyBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
