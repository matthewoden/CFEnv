defmodule CFEnv.Store do
    
    use GenServer
  
    alias CFEnv.Adapters.JSONParser
    @moduledoc """
    A GenServer, storing a parsed version of `VCAP_SERVICES` and 
    `VCAP_APPLICATION`.
    """

    @default_parser if Code.ensure_loaded?(Poison), do: JSONParser.Poison, else: nil

    @parser Application.get_env(:cf_env, :json_parser, @default_parser) || raise "No JSON parser specified in configuration, and default JSON adapter is unavailable. Please include a JSON parser. See hexdocs for details."
    
    @doc """
    Starts the Credential Store.
    """
    @spec start_link(term) :: {:ok, pid} | {:error, term}
    def start_link(_) do
        opts = [name: __MODULE__]
        GenServer.start_link(__MODULE__, [], opts)
    end

    @doc false
    @impl true    
    def init([]) do
        app = parse_application()
        services = combine_services()
        
        {:ok, %{ services: services, app: app } }
    end
  
    def combine_services() do
        vcap_services = System.get_env("VCAP_SERVICES") || "{}"
        default_services = Application.get_env(:cf_env, :default_services, %{})

        default_services
        |> Enum.map(&format_service/1)
        |> Map.new()
        |> parse_services(vcap_services)
    end

    def parse_services(default_services, vcap_services) do
        vcap_services
        |> @parser.decode!()
        |> Map.get("user-provided", [%{}])
        |> Enum.reduce(default_services, fn
                (%{"name" => name, "credentials" => credentials} = service, services) ->
                    key = Map.get(credentials, "alias", name)
                    Map.put(services, key, service)
  
                (%{"name" => name} = service, services) ->
                    Map.put(services, name, service)

                (_, services) -> 
                    services
            end)
    end

    defp format_service({key, %{"credentials" => _ } = service }) do
        {key, service}
    end

    defp format_service({key, value}) do
        {key, %{ "credentials" => value } }
    end

    defp parse_application() do
        vcap_application = System.get_env("VCAP_APPLICATION") || "{}"
        @parser.decode!(vcap_application)       
    end


    @spec get_service(String.t) :: term
    def get_service(key), do: GenServer.call(__MODULE__, {:get_service, key})

    @spec get_service(String.t, String.t) :: term
    def get_service(key, value), do: GenServer.call(__MODULE__, {:get_service, key, value})

    @spec get_services() :: map
    def get_services(), do: GenServer.call(__MODULE__, :get_services)

    @spec get_application(String.t) :: term | nil
    def get_application(key), do: GenServer.call(__MODULE__, {:get_app, key})

    @spec get_application() :: map
    def get_application(), do: GenServer.call(__MODULE__, :get_app)
    
    @spec list() :: map
    def list(), do: GenServer.call(__MODULE__, :list)
  
    def reparse(), do: GenServer.call(__MODULE__, :reparse)
    ###
    # Genserver
    ###

    @impl true
    def handle_call(:list, _from, state), do: {:reply, state, state}

    def handle_call(:get_services, _from, state) do
        {:reply, state.services, state }
    end

    def handle_call({:get_service, key}, _from, state) do
        {:reply, state.services[key], state }
    end

    def handle_call({:get_service, key, value}, _from, state) do
        {:reply, state.services[key][value], state }
    end

    def handle_call(:get_app, _from, state) do
        {:reply, state.app, state }
    end

    def handle_call({:get_app, key}, _from, state) do
        {:reply, state.app[key], state }
    end

    def handle_call(:reparse, _from, state) do
        state = Map.put(state, :services, combine_services())
        {:reply, state, state }
    end
end
      
  