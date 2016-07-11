defmodule Pxblog.UserControllerTest do
  use Pxblog.ConnCase

  alias Pxblog.TestHelper
  alias Pxblog.User

  @valid_attrs %{username: "some content", email: "some content"}
  @valid_create_attrs %{username: "some content", email: "some content", password: "foobar", password_confirmation: "foobar"}
  @invalid_attrs %{}

  setup do
    {:ok, user_role} = TestHelper.create_role(%{name: "user", admin: false})
    {:ok, non_admin_user} = TestHelper.create_user(user_role, %{email: "normal@user.com", username: "normal",
                                                                password: "test", password_confirmation: "test"})

    {:ok, admin_role} = TestHelper.create_role(%{name: "admin", admin: true})
    {:ok, admin_user} = TestHelper.create_user(admin_role, %{email: "admin@user.com", username: "admin",
                                                             password: "test", password_confirmation: "test"})

    conn = conn()
    {:ok, conn: conn, user_role: user_role, admin_role: admin_role,
          non_admin_user: non_admin_user, admin_user: admin_user}
  end

  defp valid_create_attrs(role) do
    Map.put(@valid_create_attrs, :role_id, role.id)
  end

  defp login_user(conn, user) do
    post conn, session_path(conn, :create), user: %{username: user.username, password: user.password}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  @tag admin: true
  test "renders form for new resources", %{conn: conn, admin_user: admin_user} do
    conn = conn
      |> login_user(admin_user)
      |> get(user_path(conn, :new))
    assert html_response(conn, 200) =~ "New user"
  end

  @tag admin: true
  test "redirects from new when not admin", %{conn: conn, non_admin_user: non_admin_user} do
    conn = login_user(conn, non_admin_user)
    conn = get conn, user_path(conn, :new)
    assert get_flash(conn, :error) =~ "You are not authorized"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "creates resource and redirects when data is valid", %{conn: conn, user_role: user_role, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = post conn, user_path(conn, :create), user: valid_create_attrs(user_role)
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag admin: true
  test "redirects from creating resource and redirects user is not admin", %{conn: conn, user_role: user_role, non_admin_user: non_admin_user} do
    conn = login_user(conn, non_admin_user)
    conn = post conn, user_path(conn, :create), user: valid_create_attrs(user_role)
    assert get_flash(conn, :error) =~ "You are not authorized"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  test "password_digest value gets set to a hash" do
    changeset = User.changeset(%User{}, @valid_create_attrs)
    assert Comeonin.Bcrypt.checkpw(@valid_create_attrs.password,
    Ecto.Changeset.get_change(changeset, :password_digest))
  end

  test "password_digest value does not get set if password is nil" do
    changeset = User.changeset(%User{}, %{email: "foobar@foobar.com", password: nil, password_confirmation: nil, username: "foobar"})
    refute Ecto.Changeset.get_change(changeset, :password_digest)
  end

  @tag admin: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  @tag admin: true
  test "renders form for editing chosen resource when logged in as that user", %{conn: conn, non_admin_user: non_admin_user} do
    conn = login_user(conn, non_admin_user)
    conn = get conn, user_path(conn, :edit, non_admin_user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag admin: true
  test "renders form for editing chosen resource when logged in as admin", %{conn: conn, admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = get conn, user_path(conn, :edit, admin_user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag admin: true
  test "renders form for editing chosen resource when logged in as different user", %{conn: conn, admin_user: admin_user,
                                                                                      non_admin_user: non_admin_user} do
    conn = login_user(conn, non_admin_user)
    conn = get conn, user_path(conn, :edit, admin_user)
    assert get_flash(conn, :error) =~ "You are not authorized"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "updates chosen resource and redirects when logged in as that user and data is valid", %{conn: conn, user_role: user_role,
                                                                                            non_admin_user: non_admin_user} do
    conn = login_user(conn, non_admin_user)
    conn = put conn, user_path(conn, :update, non_admin_user), user: valid_create_attrs(user_role)
    assert redirected_to(conn) == user_path(conn, :show, non_admin_user)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag admin: true
  test "updates chosen resource and redirects when logged in as admin and data is valid", %{conn: conn, user_role: user_role,
                                                                                            admin_user: admin_user} do
    conn = login_user(conn, admin_user)
    conn = put conn, user_path(conn, :update, admin_user), user: valid_create_attrs(user_role)
    assert redirected_to(conn) == user_path(conn, :show, admin_user)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag admin: true
  test "does not update chosen resource when logged in as a different user", %{conn: conn, user_role: user_role, non_admin_user: non_admin_user,
                                                                               admin_user: admin_user} do
    conn = login_user(conn, non_admin_user)
    conn = put conn, user_path(conn, :update, admin_user), user: valid_create_attrs(user_role)
    assert get_flash(conn, :error) =~ "You are not authorized"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, non_admin_user: non_admin_user} do
    conn = login_user(conn, non_admin_user)
    conn = put conn, user_path(conn, :update, non_admin_user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag admin: true
  test "deletes chosen resource when logged in as that user", %{conn: conn, user_role: user_role} do
    {:ok, user} = TestHelper.create_user(user_role, @valid_create_attrs)
    conn =
      login_user(conn, user)
      |> delete(user_path(conn, :delete, user))
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end

  @tag admin: true
  test "deletes chosen resource when logged in as an admin", %{conn: conn, user_role: user_role, admin_user: admin_user} do
    {:ok, user} = TestHelper.create_user(user_role, @valid_create_attrs)
    conn =
      login_user(conn, admin_user)
      |> delete(user_path(conn, :delete, user))
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end

  @tag admin: true
  test "redirects from deleting chosen resource when logged in as a different user", %{conn: conn, user_role: user_role,
                                                                                       non_admin_user: non_admin_user} do
    {:ok, user} = TestHelper.create_user(user_role, @valid_create_attrs)
    conn =
      login_user(conn, non_admin_user)
      |> delete(user_path(conn, :delete, user))
    assert get_flash(conn, :error) =~ "You are not authorized"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end
end
