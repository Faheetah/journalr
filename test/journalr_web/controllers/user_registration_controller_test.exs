defmodule JournalrWeb.UserRegistrationControllerTest do
  use JournalrWeb.ConnCase, async: true

  import Journalr.AccountsFixtures

  describe "GET /register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ ">Create an account<"
      assert response =~ "Or log in here</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get(Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      username = unique_username()
      email = unique_user_email()

      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => valid_user_attributes(username: username, email: email)
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ username
      assert response =~ ">Log out</a>"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ ">Create an account</"
      assert response =~ "Must have the @ sign and no spaces"
      assert response =~ "Should be at least 16 character"
    end
  end
end
