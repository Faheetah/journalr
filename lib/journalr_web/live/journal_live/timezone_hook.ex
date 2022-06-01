defmodule JournalrWeb.JournalLive.TimezoneHook do
  @moduledoc false

  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    {
      :cont,
      socket
      |> attach_hook(:local_tz, :handle_event, &timezone_hook/3)
    }
  end

  # this is only running after the page is mounted which creates a catch22
  # that we can't get the local timezone when we need to render
  defp timezone_hook("local-timezone", %{"tz_offset" => tz_offset}, socket) do
    {
      :halt,
      socket
      |> assign(:tz_offset, tz_offset)
      |> detach_hook(:local_tz, :handle_event)
    }
  end

  defp timezone_hook(_event, _params, socket), do: {:cont, socket}
end
