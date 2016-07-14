defmodule Pxblog.Factory do
  use ExMachnia.Ecto, repo: Pxblog.Repo

  alias PxBlog.User
  alias PxBlog.Role
  alias PxBlog.Post

  def factory(:role) do
    %Role{
      name: sequence(:name, &"Test Role #{&1}"),
      admin: false
    }
  end
end
