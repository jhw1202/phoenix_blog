defmodule Pxblog.SessionControllerTest do
  use Pxblog.ConnCase
  alias Pxblog.User

  setup do
    User.changeset(%User{}, %{username: "test_username", password: "test_password",
                              password_confirmation: "test_password", email: "test@test.com"})
    |> Repo.insert
    conn = conn()
    {:ok, conn: conn}
  end

  test "shows login form", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end

  test "creates new user session for a valid user", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "test_username", password: "test_password"}
    assert get_session(conn, :current_user)
    assert get_flash(conn, :info) =~ "successful"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create session for invalid credentials" do
    conn = post conn, session_path(conn, :create), user: %{username: "bad_username", password: "bad_password"}
    refute get_session(conn, :current_user)
    assert get_flash(conn, :error) =~ "Invalid"
    assert redirected_to(conn) == page_path(conn, :index)
  end
end
