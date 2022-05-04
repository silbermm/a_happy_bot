defmodule AHappyBot.PubSubChannels do
  @moduledoc """
  Defines all the pubsub channels used throughout the application
  """

  def albums_topic(), do: "albums"
  def albums_topic(search_string), do: "albums:#{search_string}"
end
