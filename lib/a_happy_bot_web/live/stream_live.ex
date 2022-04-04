defmodule AHappyBotWeb.StreamLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <p class="absolute bottom-0 text-xl"> Now Playing: <span> something </span> </p>
    """
  end

end
