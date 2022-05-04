defmodule AHappyBotWeb.StreamLive do
  use Phoenix.LiveView
  alias AHappyBot.PubSubChannels

  @page_title "Live Stream"

  @impl true
  def mount(_, _, socket) do
    if connected?(socket) do
      # subscribe to PUBSUB for new songs
      Phoenix.PubSub.subscribe(AHappyBot.PubSub, PubSubChannels.albums_topic())
    end

    {:ok, socket |> assign(song: "something", page_title: @page_title, list_albums: [])}
  end

  @impl true
  def handle_params(_, _, socket) do
    Process.send_after(self(), :new_song, 2000)
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= unless Enum.empty?(@list_albums) do %>
      <ul role="list" class="divide-y divide-gray-200 w-half">
        <%= for album <- @list_albums do %>
        <li class="py-4 flex">
          <div class="ml-3">
            <p class="text-sm font-medium text-gray-900"><%= album.album %></p>
            <p class="text-sm text-gray-500">by <%= Enum.join(album.artists, ", ") %> </p>
          </div>
        </li>
        <% end %>
      </ul> 
    <% end %>

    <p class="absolute bottom-0 left-2 text-3xl font-bold text-white font-mono"> Now Playing: <span> <%= @song %> </span> </p>
    <p class="absolute bottom-0 right-2 text-3xl font-bold text-white font-mono"> ahappydeath </p>
    """
  end

  @impl true
  def handle_info(:new_song, socket) do
    Process.send_after(self(), :new_song, 2000)
    {:noreply, socket |> assign(:song, "something else #{:rand.uniform()}")}
  end

  def handle_info({:albums, albums}, socket) do
    # Process.send_after(self(), :clear_albums, 6000)
    {:noreply, assign(socket, :list_albums, albums)}
  end

  def handle_info(:clear_albums, socket) do
    {:noreply, socket |> assign(:list_albums, [])}
  end
end
