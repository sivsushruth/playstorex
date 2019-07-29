defmodule Rankz.App do
  use Memento.Table, attributes: [:app_name, :app_installs, :developer_email, :category]

  def insert(%{
        app_installs: app_installs,
        app_name: app_name,
        developer_email: developer_email,
        category: category
      }) do
    Memento.transaction!(fn ->
      Memento.Query.write(%__MODULE__{
        app_name: app_name,
        app_installs: app_installs,
        developer_email: developer_email,
        category: category
      })
    end)

    :ok
  end
end
