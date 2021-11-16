defmodule AHappyBot.Spotify do
  @moduledoc false
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(client_id: id, client_secret: secret, refresh_token: refresh_token) do
    {:ok, %{refresh_token: refresh_token, client_id: id, client_secret: secret, access_token: ""},
     {:continue, :refresh}}
  end

  def init(_), do: {:error, "client_id, client_secret and refresh_token are required"}

  def get_current_track(), do: GenServer.call(__MODULE__, :get_current_track)

  def auth(), do: GenServer.call(__MODULE__, :auth)

  @impl true
  def handle_continue(:refresh, state), do: authenticate(state)

  @impl true
  def handle_info(:refresh, state), do: authenticate(state)

  @impl true
  def handle_call(:auth, _from, state), do: authenticate(state)

  def handle_call(:get_current_track, _from, %{access_token: token} = state) do
    resp =
      Req.get!("https://api.spotify.com/v1/me/player/currently-playing",
        headers: [{"Authorization", "Bearer " <> token}, {"Content-type", "application/json"}]
      )

    case resp.status do
      204 ->
        {:reply, :not_playing, state}

      200 ->
        title = get_in(resp.body, ["item", "name"])
        uri = get_in(resp.body, ["item", "uri"])
        artists = get_in(resp.body, ["item", "artists"])

        artists =
          artists
          |> Enum.map(&Map.get(&1, "name"))
          |> Enum.join(", ")

        {:reply, {:ok, %{title: title, artist: artists, url: build_url(uri)}}, state}

      other ->
        {:reply, {:error, other}, state}
    end
  end

  defp authenticate(%{refresh_token: refresh_token, client_id: id, client_secret: secret} = state) do
    token =
      Req.post!(
        "https://accounts.spotify.com/api/token",
        {:form, grant_type: "refresh_token", refresh_token: refresh_token},
        headers: [
          {"Authorization",
           "Basic " <>
             :base64.encode("#{id}:#{secret}")}
        ]
      ).body["access_token"]

    state = %{state | access_token: token}

    Process.send_after(self(), :refresh, 3_600_000)
    {:noreply, state}
  catch
    _e -> {:error, 401}
  end

  defp build_url(uri) do
    parts =
      uri
      |> String.split(":")
      |> Enum.drop_while(&(&1 == "spotify"))
      |> Enum.join("/")

    "https://open.spotify.com/#{parts}"
  end
end
