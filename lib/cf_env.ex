defmodule CFEnv do
  @moduledoc """
  The CFEnv behavior creates a process that stores, parses, and processes your CloudFoundry 
  environment variables and application information.

  We can define a module that represents your service bindings.

  ```
    defmodule MyApp.Env do
      use CFEnv,
        otp_app: :my_app,
        json_engine: Jason
        ...
  ```

  Configuration can be stored in application configuration, or as runtime configutation

  ## Application config example
  ```
  config :my_app, MyApp.Env
    json_engine: Jason,
    default_services: %{
      "some_db" => %{
        "username" => System.get_env("TEST_USER"),
        "password" => System.get_env("TEST_PASSWORD")
      }
    }
    ...
  ```

  ## Runtime config Example

  ```
  defmodule MyApp.Supervisor do
    # Automatically defines child_spec/1
    use Supervisor

    def start_link(arg) do
      Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
    end

    @impl true  
    def init(_arg) do
      cf_options = [
        json_engine: Jason,
        default_services: %{
          "some_db" => %{
            "username" => System.get_env("TEST_USER"),
            "password" => System.get_env("TEST_PASSWORD")
          }
        }]

      children = [
        # For Elixir v1.5 and later
        {MyApp.Env, [ cf_options ]},

        # For Elixir v1.4 and earlier
        worker(MyApp.Env, [cf_options])    
      ]

      Supervisor.init(children, strategy: :one_for_one)
    end
  end
  ```

  Once started, you can fetch your services anywhere you want. 

  ```
  defmodule MyApp.Kafka do
      def start_link() do
        creds = MyApp.Env.service_credentials("kafka_service")
        GenServer_start_link(__MODULE__, creds, name: __MODULE__)
      end

      ...
  end
  ```
  """

  @type service_name :: String.t()
  @type options :: Keyword.t()

  @doc """
  Starts the environment store. 

  ## Examples
  takes a list of options that determines how JSON should be parsed
  - `default_services` a map of services names, and credentialas to use as defaults.
  - `json_engine` - The module CFEnv will use for decoding JSON. see `CFEnv.Adapters.JSON` for
  details.

  ```
  iex> {:ok, #PID<0.43.0>} = MyApp.Env.start_link([
    json_engine: Jason,
    default_services: %{
      "some_db" => %{
        "username" => System.get_env("TEST_USER"),
        "password" => System.get_env("TEST_PASSWORD")
      }
    }])

  ```

  """
  @callback start_link(options) ::
              {:ok, pid}
              | {:error, {:already_started, pid}}
              | {:error, term}

  @doc """
  Gets the current parsed VCAP_APPLICATION as a map.

  ## Examples

  ```
  iex> MyApp.app()
  %{
    "name" => "my-app",
    "users" => nil,
    "application_name" => "my-app",
    "application_uris" => ["my-app.192.0.2.34.xip.io"],
    "application_version" => "fb8fbcc6-8d58-479e-bcc7-3b4ce5a7f0ca",
    "limits" => %{"disk" => 1024, "fds" => 16384, "mem" => 256},
    "uris" => ["my-app.192.0.2.34.xip.io"],
    "version" => "fb8fbcc6-8d58-479e-bcc7-3b4ce5a7f0ca",
    "application_id" => "fa05c1a9-0fc1-4fbd-bae1-139850dec7a3",
    "cf_api" => "https://api.example.com",
    "space_id" => "06450c72-4669-4dc6-8096-45f9777db68a",
    "space_name" => "my-space",
    "start" => "2013-08-12 00:05:29+0000"
  }
  ```
  """
  @callback app() :: map

  @doc """
  Gets the value of the `cf_api` property for the current application. Location 
  of the Cloud Controller API for the CF Deployment where the app runs.

  ## Examples
  ```
  iex> MyApp.app_cf_api()
  "https://api.example.com"
  ```
  """
  @callback app_cf_api() :: String.t()

  @doc """
  Gets the value of the `application_id` property for the current application.
  This is GUID identifying the application.

  ## Examples

  ```
  iex> MyApp.app_id()
  "fa05c1a9-0fc1-4fbd-bae1-139850dec7a3"
  ```
  """
  @callback app_id() :: String.t() | nil

  @doc """
  Gets the value of the `limits` property for the current application.

  ## Examples

  The limits to disk space, number of files, and memory permitted to the app. 
  Memory and disk space limits are supplied when the application is deployed, 
  either on the command line or in the application manifest. The number of files 
  allowed is operator-defined.

  ```
  iex> MyApp.app_limits
  ```
   %{"disk" => 1024, "fds" => 16384, "mem" => 256}
  """
  @callback app_limits() :: term

  @doc """
  Gets the value of the `application_name` property for the current application.
  This is the name assigned to the application when it was pushed.


  ## Examples

  ```
  iex> MyApp.app_name()
  "my-app"
  ```
  """
  @callback app_name() :: String.t() | nil

  @doc """
  Gets the value of the `space_id` property for the current application. This is
  GUID identifying the application’s space.

  ## Examples
  ```
  iex> MyApp.app_space_id()
  ```
  "06450c72-4669-4dc6-8096-45f9777db68a"
  """
  @callback app_space_id() :: term

  @doc """
  Gets the value of the `space_name` property for the current application. This
  is the Human-readable name of the space where the app is deployed.

  ## Examples
  ```
  iex> MyApp.app_space_name()
  "my-space"
  ```
  """
  @callback app_space_name() :: term

  @doc """
  Returns the value of the `start` property for the current application. 
  Human-readable timestamp for the time the instance was started. Not provided 
  on Diego Cells.

  ## Examples
  ```
  iex> MyApp.app_start()
  ```
  "2013-08-12 00:05:29+0000"
  """
  @callback app_start() :: term

  @doc """
  Gets the value of the `application_uris` property for the current application.
  These are the URIs assigned to the application.


  ## Examples
  ```
  iex> MyApp.app_uris()
  ["my-app.192.0.2.34.xip.io"] 
  ```
  """
  @callback app_uris() :: [String.t()] | nil

  @doc """
  Gets the value of the `application_version` property for the current application.
  This is a GUID identifying a version of the application. Each time an 
  application is pushed or restarted, this value is updated.

  ## Examples
  ```
  iex> MyApp.app_version()
  "fb8fbcc6-8d58-479e-bcc7-3b4ce5a7f0ca"
  ```
  """
  @callback app_version() :: String.t() | nil

  @doc """
  Get a service, as a map.

  ## Examples

  ```
  iex> MyApp.Env.service("cf-env-test")
  %{
    "credentials" => %{
      "database" => "database",
      "password" => "passw0rd",
      "url" => "https://example.com/",
      "username" => "userid"
    },
    "label" => "user-provided",
    "name" => "cf-env-test",
    "syslog_drain_url" => "http://example.com/syslog",
    "tags" => []
  }
  ```
  """
  @callback service(service_name) :: term

  @doc """
  Gets the `label` property for a service.

  ## Examples
  ```
  iex> MyApp.service_label("cf-env-test")
  "user-provided"
  ```
  """
  @callback service_label(service_name) :: String.t() | nil

  @doc """
  Gets the `name` property for a service. 


  ## Examples
  ```
  iex> MyApp.service_name("cf-env-test")
  "cf-env-test"
  ```

  (Given that the name is required to invoke, this is only useful when using an alias.)
  """
  @callback service_name(service_name) :: String.t() | nil

  @doc """
  Gets the `plan` property for a service.

  ## Examples
  ```
  iex> MyApp.service_plan("cf-env-test")
  "free"
  ```
  """
  @callback service_plan(service_name) :: String.t() | nil

  @doc """
  Gets the `tags` property for a service.

  ## Examples
  ```
  iex> MyApp.service_tags()
  ["smtp", "email"]
  ```
  """
  @callback service_tags(service_name) :: [String.t()]

  @doc """
  Gets the `credentials` property for a service.

  ## Examples

  ```
  iex> MyApp.Env.service_credentials("dynamo-db")
  %{"database" => "database", "password" => "passw0rd", 
    "url" => "https://example.com/",  "username" => "userid"}
  ```
  """
  @callback service_credentials(service_name) :: map

  @doc """
  Get the parsed `VCAP_SERVICES` env variable, as a map.

  ## Examples

  ```
  iex> MyApp.Env.services()
  %{
    "cf-env-test" => %{
      "credentials" => %{
        "database" => "database",
        "password" => "passw0rd",
        "url" => "https://example.com/",
        "username" => "userid"
      },
      "label" => "user-provided",
      "name" => "cf-env-test",
      "syslog_drain_url" => "http://example.com/syslog",
      "tags" => []
    }
  }
  ```
  """
  @callback services() :: term

  @doc false
  defmacro plug(middleware, opts) do
    quote do
      @__processor__ {unquote(middleware), unquote(opts)}
    end
  end

  @doc false
  defmacro __using__(use_opts) do
    quote bind_quoted: [use_opts: use_opts] do
      Module.register_attribute(__MODULE__, :__processor__, accumulate: true)
      use GenServer
      import CFEnv
      @behaviour CFEnv
      @opts use_opts
      @before_compile CFEnv

      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)
      end

      @doc false
      @impl true
      def init(opts) do
        with {:ok, config} <- config(opts),
             {:ok, services} = parse_services(config) |> post_process(),
             app <- parse_application(config) do
          {:ok, %{services: services, app: app, config: config}}
        else
          {:error, reason} ->
            {:stop, reason}

          otherwise ->
            {:error, ["Unknown configuration problem.", otherwise]}
        end
      end

      defp config(opts) do
        has_poison = if Code.ensure_loaded?(Poison), do: Poison, else: nil
        has_jason = if Code.ensure_loaded?(Jason), do: Jason, else: nil
        otp_app = Keyword.get(@opts, :otp_app)

        app_config = Application.get_env(otp_app, __MODULE__, [])
        inferred_config = [json_engine: has_jason || has_poison, otp_app: otp_app]

        final_opts = Keyword.merge(inferred_config, app_config) |> Keyword.merge(opts)

        if nil == Keyword.get(final_opts, :json_engine) do
          {:error, "No JSON engine specified. Cannot decode JSON"}
        else
          {:ok, final_opts}
        end
      end

      defp parse_services(config) do
        engine = Keyword.get(config, :json_engine)

        default_services =
          config
          |> Keyword.get(:default_services, %{})
          |> Enum.map(&format_service/1)
          |> Map.new()

        engine.decode!(System.get_env("VCAP_SERVICES") || "{}")
        |> Map.get("user-provided", [%{}])
        |> Enum.reduce(default_services, fn
          %{"name" => name, "credentials" => credentials} = service, services ->
            key = Map.get(credentials, "alias", name)
            Map.put(services, key, service)

          %{"name" => name} = service, services ->
            Map.put(services, name, service)

          _, services ->
            services
        end)
      end

      defp format_service({key, %{"credentials" => _} = service}) do
        {key, service}
      end

      defp format_service({key, value}) do
        {key, %{"credentials" => value}}
      end

      defp parse_application(config) do
        engine = Keyword.get(config, :json_engine)
        vcap_application = System.get_env("VCAP_APPLICATION") || "{}"
        engine.decode!(vcap_application)
      end

      ###
      # Application 
      ###

      @doc false
      def app(), do: GenServer.call(__MODULE__, :get_app)

      @doc false
      defp app_property(property), do: GenServer.call(__MODULE__, {:get_app, property})

      @doc false
      def app_id(), do: app_property("application_id")

      @doc false
      def app_name(), do: app_property("application_name")

      @doc false
      def app_uris(), do: app_property("application_uris")

      @doc false
      def app_version(), do: app_property("application_version")

      @doc false
      def app_cf_api(), do: app_property("cf_api")

      @doc false
      def app_limits(), do: app_property("limits")

      @doc false
      def app_space_id(), do: app_property("space_id")

      @doc false
      def app_space_name(), do: app_property("space_name")

      @doc false
      def app_start(), do: app_property("start")

      ###
      # service
      ###

      @doc false
      def service(service), do: GenServer.call(__MODULE__, {:get_service, service})

      @doc false
      def services(), do: GenServer.call(__MODULE__, :get_services)

      @doc false
      defp service_property(service, property),
        do: GenServer.call(__MODULE__, {:get_service, service, property})

      @doc false
      def service_label(name), do: service_property(name, "label")

      @doc false
      def service_name(name), do: service_property(name, "name")

      @doc false
      def service_plan(name), do: service_property(name, "plan")

      @doc false
      def service_tags(name), do: service_property(name, "tags") || []

      @doc false
      def service_credentials(name), do: service_property(name, "credentials") || %{}

      @doc false
      def config(), do: GenServer.call(__MODULE__, :get_config)
      ###
      # Hooks
      ###

      ###
      # Genserver
      ###

      @impl true
      @doc false
      def handle_call(:get_services, _from, state) do
        {:reply, state.services, state}
      end

      def handle_call({:get_service, service}, _from, state) do
        {:reply, state.services[service], state}
      end

      def handle_call({:get_service, service, property}, _from, state) do
        {:reply, state.services[service][property], state}
      end

      def handle_call(:get_app, _from, state) do
        {:reply, state.app, state}
      end

      def handle_call({:get_app, key}, _from, state) do
        {:reply, state.app[key], state}
      end

      def handle_call(:get_config, _from, state) do
        {:reply, state.config, state}
      end
    end
  end

  # run post processors
  defmacro __before_compile__(_env) do
    quote location: :keep do
      @doc false
      def post_process(services), do: process_services(services, @__processor__)

      defp process_services(services, []), do: {:ok, services}

      defp process_services(services, [{processor, opts} | rest]) do
        case processor.init(services, opts) do
          {:ok, state} ->
            services =
              services
              |> pmap(fn service -> processor.call(service, state) end)
              |> Map.new()

            process_services(services, rest)

          {:error, term} = failure ->
            failure
        end
      end

      @doc false
      defp pmap(collection, func) do
        collection
        |> Enum.map(&Task.async(fn -> func.(&1) end))
        |> Enum.map(&Task.await/1)
      end
    end
  end
end
