defmodule AHappyBot.Discogs do
  @moduledoc """
  Interact with the [Discogs](https://www.discogs.com/developers/) API

  On startup it pulls all collections from discogs and puts them into 
  the process state as a MapSet.

  This makes is searchable by artist or album name.
  """

  use GenServer
  require Logger

  @user_agent "AHappyBot/1.0 +https://ahappybot.digitalocean.app"
  @username "silbermm"
  @url "https://api.discogs.com"

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    token = Keyword.get(opts, :token)
    GenServer.start_link(__MODULE__, token, name: name)
  end

  @impl true
  def init(token) when token != "",
    do: {:ok, %{token: token, records: MapSet.new()}, {:continue, :load}}

  @impl true
  def init(_), do: {:error, "token is required"}

  @doc "Lists all the records"
  def list_collection(pid \\ __MODULE__), do: GenServer.call(pid, :all_records)

  @doc "Find a record based on artist name"
  def find_by_artist(pid \\ __MODULE__, artist_name),
    do: GenServer.call(pid, {:search_by_artist, artist_name})

  @doc "Find a record based on the album name"
  def find_by_album(pid \\ __MODULE__, album_name),
    do: GenServer.call(pid, {:search_by_album, album_name})

  @impl true
  def handle_call(:all_records, _from, %{records: records} = state),
    do: {:reply, MapSet.to_list(records), state}

  def handle_call({:search_by_artist, artist_name}, _from, %{records: records} = state) do
    matches = Enum.filter(records, &artist_jaro_search(artist_name, &1))
    {:reply, matches, state}
  end

  def handle_call({:search_by_album, album_name}, _from, %{records: records} = state) do
    matches = Enum.filter(records, &album_jaro_search(album_name, &1))
    {:reply, matches, state}
  end

  defp artist_jaro_search(artist_name, record) do
    names = normalize_names(record.artists)
    [search_string] = normalize_names([artist_name])
    Enum.any?(names, fn n -> String.jaro_distance(n, search_string) > 0.75 end)
  end

  defp album_jaro_search(album_name, record) do
    names = normalize_names([record.album])
    [search_string] = normalize_names([album_name])
    Enum.any?(names, fn n -> String.jaro_distance(n, search_string) > 0.75 end)
  end

  defp normalize_names(names) do
    Enum.map(names, fn name ->
      name
      |> String.downcase()
      |> String.replace(" ", "")
    end)
  end

  @impl true
  def handle_continue(:load, %{token: token, records: records} = state) do
    case get_collection(token) do
      {:ok, data} ->
        new_records = MapSet.union(records, data)
        # TODO: save to ETS
        {:noreply, %{state | records: new_records}}

      {:error, _status_code} ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:next_page, url}, %{token: token, records: records} = state) do
    with resp <- Req.get!(url, headers: headers(token)),
         :ok <- queue_up_next_page(resp),
         {:ok, data} <- handle_response(resp) do
      # save to ETS
      new_records = MapSet.union(records, data)
      {:noreply, %{state | records: new_records}}
    else
      err ->
        Logger.error(inspect(err))
        {:noreply, state}
    end
  end

  defp get_collection(token) do
    with resp <-
           Req.get!("#{@url}/users/#{@username}/collection/folders/0/releases?sort=artist",
             headers: headers(token)
           ),
         :ok <- queue_up_next_page(resp) do
      handle_response(resp)
    else
      err ->
        Logger.error(inspect(err))
        raise err
    end
  end

  defp queue_up_next_page(%{body: %{"pagination" => %{"urls" => %{"next" => next}}}}),
    do: Process.send(self(), {:next_page, next}, [])

  defp queue_up_next_page(_), do: Logger.info("No pages of data left")

  defp headers(token),
    do: [{"Authorization", "Discogs token=#{token}"}, {"User-Agent", @user_agent}]

  defp handle_response(%{status: 200, body: %{"releases" => releases}}),
    do: {:ok, Enum.reduce(releases, MapSet.new(), &build_release/2)}

  defp handle_response(%{status: status}), do: {:error, status}

  defp build_release(%{"basic_information" => info}, set) do
    MapSet.put(set, %{
      artists: build_artist_list(info),
      album: get_in(info, ["title"]),
      genres: get_in(info, ["genres"])
    })
  end

  def build_artist_list(%{"artists" => artists}),
    do: Enum.map(artists, fn %{"name" => name} -> name end)
end
