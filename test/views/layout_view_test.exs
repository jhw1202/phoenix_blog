defmodule Pxblog.LayoutViewTest do
  use Pxblog.ConnCase

  alias Pxblog.TestHelper
  alias Pxblog.LayoutView
  alias Pxblog.User

  setup do
    {:ok, role} = TestHelper.create_role(%{name: "User Role", admin: false})
  {:ok, user} = TestHelper.create_user(role, %{email: "test@test.com", username: "testuser",
                                           password: "test", password_confirmation: "test"})
    conn = conn()
    {:ok, conn: conn, user: user}
  end

  test "current_user returns user in session", %{conn: conn, user: user} do
    conn = post conn, session_path(conn, :create), user: %{username: user.username, password: user.password}
    assert LayoutView.current_user(conn)
  end

  test "current_user returns nil if no user in session", %{conn: conn, user: user} do
    user = Repo.get_by(User, %{username: user.username})
    conn = delete conn, session_path(conn, :delete, user)
    refute LayoutView.current_user(conn)
  end
end
