defmodule AHappyBot.ChatHandler do
  @moduledoc false

  use TMI.Handler

  @commands %{
    "song" => "shows the currently playing track",
    "echo" => "repeats back what you say"
  }

  @impl true
  def handle_message("!" <> command, sender, chat) do
    case command do
      "song" -> currently_playing(chat)
      "help " <> rest -> show_help(chat, rest)
      "help" -> show_help(chat, "all")
      "echo " <> rest -> TMI.message(chat, rest)
      "dance" -> TMI.action(chat, "dances for #{sender}")
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
end
