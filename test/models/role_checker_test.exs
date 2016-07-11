defmodule Pxblog.RoleCheckerTEst do
  use Pxblog.ModelCase

  alias Pxblog.TestHelper
  alias Pxblog.RoleChecker

  test "#is_admin? is true when user is admin" do
    {:ok, role} = TestHelper.create_role(%{name: "Admin Role", admin: true})
    {:ok, user} = TestHelper.create_user(role, %{email: "test@test.com", username: "user",
                                                 password: "test", password_confirmation: "test"})
    assert RoleChecker.is_admin?(user)
  end


  test "#is_admin? is true when user is admin" do
    {:ok, role} = TestHelper.create_role(%{name: "User Role", admin: false})
    {:ok, user} = TestHelper.create_user(role, %{email: "test@test.com", username: "user",
                                                 password: "test", password_confirmation: "test"})
    refute RoleChecker.is_admin?(user)
  end
end
