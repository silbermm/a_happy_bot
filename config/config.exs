import Config

config :a_happy_bot,
  spotify_client_id: System.fetch_env!("SPOTIFY_CLIENT_ID"),
  spotify_client_secret: System.fetch_env!("SPOTIFY_CLIENT_SECRET"),
  spotify_refresh_token: System.fetch_env!("SPOTIFY_REFRESH_TOKEN"),
  twitch_user: System.fetch_env!("TWITCH_USER"),
  twitch_pass: System.fetch_env!("TWITCH_PASS"),
  twitch_chats: ["a_happy_death"],
  capabilities: ['membership']
