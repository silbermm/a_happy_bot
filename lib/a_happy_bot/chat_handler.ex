defmodule AHappyBot.ChatHandler do
  @moduledoc false

  use TMI.Handler

  @commands %{
    "song" => "shows the currently playing track",
    "echo" => "repeats back what you say",
    "dance" => "dances for the requestor",
    "albums" => "list albums in my record collection - takes a album name to search for as well",
    "artists" => "list the artists in my record collection - takes a name to search for as well"
  }

  @impl true
  def handle_message("!" <> command, sender, chat) do
    case command do
      "song" -> currently_playing(chat)
      "help " <> rest -> show_help(chat, rest)
      "help" -> show_help(chat, "all")
      "echo " <> rest -> TMI.message(chat, rest)
      "dance" -> TMI.action(chat, "dances for #{sender}")
      "albums " <> rest -> list_albums_by_name(chat, rest)
      "albums" -> list_albums(chat)
      "artists " <> rest -> TMI.action(chat, "searches for #{rest}")
      "artists" -> TMI.action(chat, "searches for all artists")
      _ -> TMI.message(chat, "unrecognized command")
    end
  end

  def handle_message(message, sender, chat) do
    Logger.debug("Message in #{chat} from #{sender}: #{message}")
  end

  defp show_help(chat, "all") do
    for {command, description} <- @commands do
      TMI.message(chat, "#{command} - #{description}")
    end
  end

  defp show_help(chat, rest) do
    case Map.get(@commands, rest, nil) do
      nil -> show_help(chat, "all")
      res -> TMI.message(chat, "#{rest} - #{res}")
    end
  end

  defp currently_playing(chat) do
    case AHappyBot.Spotify.get_current_track() do
      {:ok, song} ->
        TMI.message(chat, "NOW PLAYING: #{song.title} by #{song.artist} #{song.url}")

      :not_playing ->
        TMI.message(chat, "NO MUSIC RIGHT NOW")

      {:error, 401} ->
        AHappyBot.Spotify.auth()
        currently_playing(chat)
    end
  end

  defp list_albums(chat) do
    AHappyBot.Discogs.list_collection()
    |> Enum.each(fn record ->
      msg = "<<\"#{record.album}\" by \"#{Enum.join(record.artists, ", ")}\">>"
      TMI.message(chat, msg)
    end)
  end

  defp list_albums_by_name(chat, name) do
    total =
      AHappyBot.Discogs.find_by_album(name)
      |> Enum.reduce(0, fn record, total_num ->
        msg = "<<\"#{record.album}\" by \"#{Enum.join(record.artists, ", ")}\">>"
        TMI.message(chat, msg)
        total_num + 1
      end)

    if total < 1 do
      TMI.message(chat, "Nothing found for \"#{name}\"")
    end
  end
end
