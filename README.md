# AHappyBot

A bot for Twitch that will
  * [x] display your current Spotify artist/song.
  * [x] show help

## Building and Running

### Prerequisites

  * Elixir 1.12 or higher
  * Spotify Application - https://developer.spotify.com/dashboard/
      * Client Id
      * Client Secret
      * Refresh Token
  * Twitch Account
      * Username
      * OAuth Password - https://twitchapps.com/tmi

Set the correct env variables

  * SPOTIFY_CLIENT_ID
  * SPOTIFY_CLIENT_SECRET
  * SPOTIFY_REFRESH_TOKEN
  * TWITCH_USER
  * TWITCH_PASS

Build the release

```bash
MIX_ENV=prod mix release
```

Run the Release

```bash
./_build/prod/rel/ahappybot/bin/ahappybot
```

## Deploying
TODO
