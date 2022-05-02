defmodule AHappyBot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    if function_exported?(Mix, :env, 0) && Mix.env() != :prod do
      Dotenv.load()
      Mix.Task.run("loadconfig")
    end

    spotify_config = [
      client_id: Application.get_env(:a_happy_bot, :spotify_client_id),
      client_secret: Application.get_env(:a_happy_bot, :spotify_client_secret),
      refresh_token: Application.get_env(:a_happy_bot, :spotify_refresh_token)
    ]

    config = [
      user: Application.get_env(:a_happy_bot, :twitch_user),
      pass: Application.get_env(:a_happy_bot, :twitch_pass),
      chats: Application.get_env(:a_happy_bot, :twitch_chats),
      handler: AHappyBot.ChatHandler,
      capabilities: Application.get_env(:a_happy_bot, :capabilities)
    ]

    discogs_config = [
      token: Application.get_env(:a_happy_bot, :discogs_token, "")
    ]

    children = [
      AHappyBotWeb.Telemetry,
      {Phoenix.PubSub, name: AHappyBot.PubSub},
      AHappyBotWeb.Endpoint,
      {TMI.Supervisor, config},
      {AHappyBot.Spotify, spotify_config},
      {AHappyBot.Discogs, discogs_config}
    ]

    opts = [strategy: :one_for_one, name: AHappyBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AHappyBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
