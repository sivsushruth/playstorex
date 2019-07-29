defmodule Rankz.Supervisor do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Rankz.Router, []),
      {Task, fn -> Rankz.run_scraper() end}
    ]

    opts = [strategy: :one_for_one, name: Rankz.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
