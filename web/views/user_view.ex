defmodule Pxblog.UserView do
  use Pxblog.Web, :view

  def roles_for_select(roles) do
    roles
    #same as Enum.map(fn (role) -> ["#{role.name"}: role.id] end)
    |> Enum.map(&["#{&1.name}": &1.id])
    |> List.flatten
  end
end
