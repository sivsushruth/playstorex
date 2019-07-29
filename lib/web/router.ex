defmodule Rankz.Router do
  use Plug.Router
  import Plug.Conn
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http(Rankz.Router, [])
  end

  get "/", private: %{protected: false} do
    apps = Rankz.WebService.get_apps()
    conn |> send_resp(200, Poison.encode!(apps))
  end

  get "/category/:category", private: %{protected: false} do
    apps = Rankz.WebService.get_apps_by_category(conn.params["category"])
    conn |> send_resp(200, Poison.encode!(apps))
  end

  get "/app/:app_name", private: %{protected: false} do
    app = Rankz.WebService.get_app_by_name(conn.params["app_name"])
    conn |> send_resp(200, Poison.encode!(app))
  end

  match _ do
    conn |> send_resp(404, "Not found")
  end
end
