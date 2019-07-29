defmodule Rankz.Scraper do
  use Hound.Helpers
  require Logger

  def run() do
    init_db()
    init_session()

    navigate_home()
    map_categories()
  end

  def navigate_home() do
    navigate_to("https://play.google.com/store/apps")
  end

  def map_categories() do
    find_element(:id, "action-dropdown-children-Categories")
    |> find_all_within_element(:tag, "a")
    |> Enum.map(&{inner_text(&1), attribute_value(&1, "href")})
    |> Task.async_stream(
      fn {t, l} ->
        process_category_element(t, l)
      end,
      max_concurrency: 2,
      timeout: :infinity
    )
    |> Stream.run()
  end

  def process_category_element(category, link) do
    init_session()
    navigate_to(link)

    find_all_elements(:tag, "a")
    |> case do
      {:error, _} -> []
      i -> i
    end
    |> Enum.filter(fn x ->
      href = attribute_value(x, "href")
      href && String.contains?(href, "store/apps/details")
    end)
    |> Enum.uniq_by(&attribute_value(&1, "href"))
    |> process_app_links(category)
  end

  def process_app_links(elements, category) when is_list(elements) do
    elements
    |> Enum.map(&attribute_value(&1, "href"))
    |> Enum.map(&process_app_link(&1, category))
  end

  def process_app_link(link, category) do
    navigate_to(link)

    app_installs =
      execute_script(
        "return Array.from(document.querySelectorAll('div')).find(el => el.textContent === 'Installs').parentElement.children[1].children[0].innerText;"
      )

    developer_email =
      execute_script(
        "return Array.from(document.querySelectorAll('div')).find(el => el.textContent === 'Developer').parentElement.innerText.match(/([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9._-]+)/gi)[0]"
      )

    app_name = execute_script("return document.querySelector(\"h1\").innerText")

    [app_installs, app_name, developer_email]
    |> Enum.any?(fn x ->
      case x do
        {:error, _} -> true
        _ -> false
      end
    end)
    |> case do
      false ->
        handle_extracted_data(%{
          app_installs: app_installs,
          app_name: app_name,
          developer_email: developer_email,
          category: category
        })

      _ ->
        :noop
    end
  end

  def handle_extracted_data(data) do
    Rankz.App.insert(data)
  end

  def init_session() do
    Hound.start_session(
      driver: %{
        browserName: "chrome",
        chromeOptions: %{
          "args" => [
            "--user-agent=Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
            "--no-first-run",
            "--disable-gpu",
            "--headless"
          ],
          "prefs" => %{
            "profile" => %{
              "default_content_setting_values" => %{"images" => 2}
            }
          }
        }
      }
    )
  end

  def init_db() do
    Memento.Table.create!(Rankz.App)
  end

  def on_exit(reason) do
    Logger.error(reason)
  end

  def setup(args) do
    Logger.info(args)
  end
end
