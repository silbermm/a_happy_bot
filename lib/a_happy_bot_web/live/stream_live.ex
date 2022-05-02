defmodule AHappyBotWeb.StreamLive do
  use Phoenix.LiveView

  @impl true
  def mount(_, _, socket) do
    if connected?(socket) do
      # subscribe to PUBSUB for new songs
    end

    {:ok, socket |> assign(:song, "something")}
  end

  @impl true
  def handle_params(_, _, socket) do
    Process.send_after(self(), :new_song, 2000)
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <p class="absolute bottom-0 left-2 text-3xl font-bold text-white font-mono"> Now Playing: <span> <%= @song %> </span> </p>
    <p class="absolute bottom-0 right-2 text-3xl font-bold text-white font-mono"> ahappydeath </p>
    """
  end

  @impl true
  def handle_info(:new_song, socket) do
    Process.send_after(self(), :new_song, 2000)
    {:noreply, socket |> assign(:song, "something else #{:rand.uniform()}")}
  end
end
