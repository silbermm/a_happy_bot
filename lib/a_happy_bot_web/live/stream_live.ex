defmodule AHappyBotWeb.StreamLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <p class="absolute bottom-0 left-2 text-3xl font-bold text-white font-mono"> Now Playing: <span> something </span> </p>
    <p class="absolute bottom-0 right-2 text-3xl font-bold text-white font-mono"> ahappydeath </p>
    """
  end

end
