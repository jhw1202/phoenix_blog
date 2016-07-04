defmodule Pxblog.UserTest do
  use Pxblog.ModelCase

  alias Pxblog.TestHelper
  alias Pxblog.User


  @valid_attrs %{username: "some content", email: "some content", password: "foobar", password_confirmation: "foobar"}
  @invalid_attrs %{}

  setup do
    {:ok, role} = TestHelper.create_role(%{name: "user", admin: false})
    {:ok, role: role}
  end

  defp valid_attrs(role) do
    Map.put(@valid_attrs, :role_id, role.id)
  end

  test "changeset with valid attributes", %{role: role} do
    changeset = User.changeset(%User{}, valid_attrs(role))
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
