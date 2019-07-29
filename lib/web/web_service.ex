defmodule Rankz.WebService do
  def get_apps() do
    Memento.transaction!(fn ->
      Memento.Query.all(Rankz.App)
    end)
  end

  def get_apps_by_category(category) do
    Memento.transaction!(fn ->
      Memento.Query.select(Rankz.App, {:==, :category, category})
    end)
  end

  def get_app_by_name(app_name) do
    Memento.transaction!(fn ->
      Memento.Query.select(Rankz.App, {:==, :app_name, app_name}, limit: 1)
    end)
    |> case do
      [] -> nil
      [app] -> app
    end
  end
end
