defmodule AHappyBot.Discogs do
  @moduledoc """
  Interact with the [Discogs](https://www.discogs.com/developers/) API

  On startup it pulls all collections from discogs and puts it in ETS.
  This makes is searchable by artist or album name.
  """
  use GenServer
  require Logger

  @user_agent "AHappyBot/1.0 +https://ahappybot.digitalocean.app"
  @url "https://api.discogs.com"
  @username "silbermm"

  def start_link(token, opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, token, name: name)
  end

  @impl true
  def init(token) when token != "" do
    {:ok, %{token: token}, {:continue, :load}}
  end

  def init(_), do: {:error, "token is required"}

  @impl true
  def handle_continue(:load, state) do 
    list_collection()
  end

  def token(), do: Application.fetch_env!(:a_happy_bot, :discogs_token)

  defp list_collection(opts \\ []) do
    folder = Keyword.get(opts, :folder, nil)

    if folder do
      Logger.debug("folder isn't available yet")
    end

    resp =
      Req.get!("#{@url}/users/#{@username}/collection/folders/0/releases?sort=artist",
        headers: headers()
      )

    handle_response(resp)
    Process.send_after(self(), :load, 3_600_000)
  end

  defp headers() do
    [{"Authorization", "Discogs token=#{token()}"}, {"User-Agent", @user_agent}]
  end

  defp handle_response(%{status: 200, body: %{"releases" => releases}}) do
    Enum.map(releases, &build_release/1)
  end

  defp handle_response(%{status: status}) do
    Logger.error("Invalid response from Discogs: #{status}")
    {:error, :invalid_response}
  end

  defp build_release(%{"basic_information" => info}) do
    %{
      artists: build_artist_list(info),
      album: get_in(info, ["title"]),
      genres: get_in(info, ["genres"])
    }
  end

  def build_artist_list(%{"artists" => artists}) do
    Enum.map(artists, fn %{"name" => name} -> name end)
  end
end
