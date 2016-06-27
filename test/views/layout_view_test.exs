defmodule Pxblog.LayoutViewTest do
  use Pxblog.ConnCase
  alias Pxblog.LayoutView
  alias Pxblog.User

  setup do
    User.changeset(%User{}, %{username: "test_username", password: "test_password",
                              password_confirmation: "test_password", email: "test@test.com"})
    |> Repo.insert
    conn = conn()
    {:ok, conn: conn}
  end

  test "current_user returns user in session", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "test_username", password: "test_password"}
    assert LayoutView.current_user(conn)
  end

  test "current_user returns nil if no user in session", %{conn: conn} do
    user = Repo.get_by(User, %{username: "test_username"})
    conn = delete conn, session_path(conn, :delete, user)
    refute LayoutView.current_user(conn)
  end
end
