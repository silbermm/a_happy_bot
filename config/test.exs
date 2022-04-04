import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :a_happy_bot, AHappyBotWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "03VXIq1Pwurrr6HfSEv4o62BWJnNnNWZVdLHznSMQAFAI9LDZ06cby7E3qk0RZWO",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
