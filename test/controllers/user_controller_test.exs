defmodule Pxblog.UserControllerTest do
  use Pxblog.ConnCase

  alias Pxblog.TestHelper
  alias Pxblog.User

  @valid_attrs %{username: "some content", email: "some content"}
  @valid_create_attrs %{username: "some content", email: "some content", password: "foobar", password_confirmation: "foobar"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, user_role} = TestHelper.create_role(%{name: "user", admin: false})
    {:ok, admin_role} = TestHelper.create_role(%{name: "admin", admin: true})
    {:ok, conn: conn, user_role: user_role, admin_role: admin_role}
  end

  defp valid_create_attrs(role) do
    Map.put(@valid_create_attrs, :role_id, role.id)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, user_role: user_role} do
    conn = post conn, user_path(conn, :create), user: valid_create_attrs(user_role)
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
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

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
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

  test "renders form for editing chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, user_role: user_role} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: valid_create_attrs(user_role)
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "deletes chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
