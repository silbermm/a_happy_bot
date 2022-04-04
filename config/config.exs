# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config


config :a_happy_bot,
  spotify_client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  spotify_client_secret: System.get_env("SPOTIFY_CLIENT_SECRET"),
  spotify_refresh_token: System.get_env("SPOTIFY_REFRESH_TOKEN"),
  twitch_user: System.get_env("TWITCH_USER"),
  twitch_pass: System.get_env("TWITCH_PASS"),
  twitch_chats: ["a_happy_death"],
  capabilities: ['membership']

# Configures the endpoint
config :a_happy_bot, AHappyBotWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AHappyBotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AHappyBot.PubSub,
  live_view: [signing_salt: "Ei2GvjqB"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tailwind, 
  version: "3.0.12",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
