defmodule CFEnv.Middleware.Base64 do
  @moduledoc """
  Base64 Decodes a service credential, when given a list of services. Assumes
  all values on the service are encoded.
  
  ```
  defmodule MyApp.Env do
    use CFEnv, otp_app: my_app

    plug CFEnv.Middleware.Base64, services: ["db", "AWS"]

  end
  ```
  """
  @behaviour CFEnv.Middleware

  def init(_services, opts) do
    service_keys = Keyword.get(opts, :services, [])
    {:ok, %{services: service_keys}}
  end

  def call({name, %{"credentials" => credentials} = service}, state) do
    credentials =
      if name in state.services do
        crawl(credentials, &Base.decode64/1)
      else
        credentials
      end

    {name, Map.put(service, "credentials", credentials)}
  end

  defp crawl(map, callback) when is_map(map) do
    Enum.map(map, fn {key, value} -> {key, crawl(value, callback)} end) |> Map.new()
  end

  defp crawl(value, callback) when is_binary(value) do
    case callback.(value) do
      {:ok, new_value} ->
        new_value

      otherwise ->
        value
    end
  end

  defp crawl(otherwise, _callback), do: otherwise
end
