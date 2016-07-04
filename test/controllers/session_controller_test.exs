defmodule Pxblog.SessionControllerTest do
  use Pxblog.ConnCase

  alias Pxblog.TestHelper
  alias Pxblog.Repo
  alias Pxblog.User

  setup do
    {:ok, role} = TestHelper.create_role(%{name: "User", admin: false})
    {:ok, _user} = TestHelper.create_user(role, %{username: "test", email: "test@test.com",
                                                  password: "test", password_confirmation: "test"})
    conn = conn()
    {:ok, conn: conn}
  end

  test "shows login form", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end

  test "creates new user session for a valid user", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "test", password: "test"}
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

  test "deletes user session", %{conn: conn} do
    user = Repo.get_by(User, %{username: "test"})
    conn = post conn, session_path(conn, :create), user: %{username: "test", password: "test"}
    conn = delete conn, session_path(conn, :delete, user)
    refute get_session(conn, :current_user)
    assert get_flash(conn, :info) =~ "Signed out"
    assert redirected_to(conn) == page_path(conn, :index)
  end
end
