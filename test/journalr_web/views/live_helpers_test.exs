defmodule JournalrWeb.LiveHelpersTest do
  use ExUnit.Case, async: true

  test "inflexes days" do
    rendered = Enum.map(1..31, fn day -> JournalrWeb.LiveHelpers.format_datetime(%{year: 2022, month: 4, day: day}) end)
    expected = ["April 1st, 2022", "April 2nd, 2022", "April 3th, 2022", "April 4th, 2022",
                "April 5th, 2022", "April 6th, 2022", "April 7th, 2022", "April 8th, 2022",
                "April 9th, 2022", "April 10th, 2022", "April 11th, 2022", "April 12th, 2022",
                "April 13th, 2022", "April 14th, 2022", "April 15th, 2022", "April 16th, 2022",
                "April 17th, 2022", "April 18th, 2022", "April 19th, 2022", "April 20th, 2022",
                "April 1st, 2022", "April 22nd, 2022", "April 23rd, 2022", "April 24th, 2022",
                "April 25th, 2022", "April 26th, 2022", "April 27th, 2022", "April 28th, 2022",
                "April 29th, 2022", "April 30th, 2022", "April 31st, 2022"]
    assert rendered == expected
  end

  test "formats month names" do
    rendered = Enum.map(1..12, fn month -> JournalrWeb.LiveHelpers.format_datetime(%{year: 2022, month: month, day: 1}) end)
    expected = ["January 1st, 2022", "February 1st, 2022", "March 1st, 2022",
                "April 1st, 2022", "May 1st, 2022", "June 1st, 2022", "July 1st, 2022",
                "August 1st, 2022", "September 1st, 2022", "October 1st, 2022",
                "November 1st, 2022", "December 1st, 2022"]
    assert rendered == expected
  end
end
