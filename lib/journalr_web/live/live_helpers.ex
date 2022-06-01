defmodule JournalrWeb.LiveHelpers do
  @moduledoc false

  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.HTML.Tag

  alias Phoenix.LiveView.JS

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.journal_index_path(@socket, :index)}>
        <.live_component
          module={JournalrWeb.JournalLive.FormComponent}
          id={@journal.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.journal_index_path(@socket, :index)}
          journal: @journal
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>
          <%= live_patch "X",
            to: @return_to,
            id: "close",
            class: "phx-modal-close",
            phx_click: hide_modal()
          %>
        <% else %>
         <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>✖</a>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end

  @days %{1 => "January", 2 => "February", 3 => "March", 4 => "April", 5 => "May", 6 => "June", 7 => "July", 8 => "August", 9 => "September", 10 => "October", 11 => "November", 12 => "December"}

  def format_datetime(datetime, nil) do
    "#{@days[datetime.month]} #{inflex(datetime.day)}, #{datetime.year}"
  end

  def format_datetime(datetime, tz_offset) do
    hour = convert_hour(datetime.hour - div(tz_offset, 60))
    minute = pad_minute(datetime.minute - rem(tz_offset, 60))
    "#{@days[datetime.month]} #{inflex(datetime.day)}, #{datetime.year} #{hour}:#{minute}#{am_or_pm(datetime.hour)}"
  end

  defp convert_hour(0), do: "12"
  defp convert_hour(12), do: "12"
  defp convert_hour(hour), do: rem(hour, 12)

  defp pad_minute(minute), do: String.pad_leading(Integer.to_string(minute), 2, "0")

  defp am_or_pm(hour) when hour > 12, do: "PM"
  defp am_or_pm(_), do: "AM"

  defp inflex(1), do: "1st"
  defp inflex(2), do: "2nd"
  defp inflex(3), do: "3nd"
  # 4th 5th 6th 7th 8th 9th 10th
  # 11th 12th 13th 14th 15th 16th 17th 18th 19th 20th
  defp inflex(21), do: "21st"
  defp inflex(22), do: "22nd"
  defp inflex(23), do: "23rd"
  # 24th 25th 26th 27th 28th 29th 30th
  defp inflex(31), do: "31st"
  defp inflex(n), do: "#{n}th"

  def format_page(content) do
    content
    |> String.split("\n\n")
    |> Enum.map(fn s -> Tag.content_tag(:p, parse_hashtags(s), class: "py-2") end)
  end

  @alphanums Enum.into(?a..?z, []) ++ Enum.into(?A..?Z, []) ++ Enum.into(?0..?9, [])

  defp parse_hashtags(content), do: parse_hashtags(content, [])
  defp parse_hashtags("", result), do: Enum.reverse(result)
  defp parse_hashtags(<<?#::8, rest::binary>>, result) do
    parse_hashtags(rest, result, "")
  end
  defp parse_hashtags(<<b::8, rest::binary>>, result) do
    parse_hashtags(rest, [b | result])
  end
  defp parse_hashtags("", result, hashtag), do: [format_hashtag(hashtag) | result]
  defp parse_hashtags(<<b::8, rest::binary>> = content, result, hashtag) do
    if b in @alphanums do
      parse_hashtags(rest, result, hashtag <> <<b>>)
    else
      parse_hashtags(content, [format_hashtag(hashtag) | result])
    end
  end

  defp format_hashtag(hashtag) do
    Tag.content_tag(:a, "#" <> hashtag, href: "/search?tag=#{hashtag}", class: "font-bold")
  end
end
