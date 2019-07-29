defmodule Mix.Tasks.Rankz.Scraper do
  use Mix.Task

  @shortdoc "Runs the scraper function."

  def run(args) do
    init()
    Rankz.run_scraper()
  end

  def init() do
    Application.ensure_all_started(:hound)
    Application.ensure_all_started(:readability)
  end
end
