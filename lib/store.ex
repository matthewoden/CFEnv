defmodule CFEnv.Store do
    
    use GenServer
  
    alias CFEnv.Adapters.JSONParser
    @moduledoc """
    A GenServer, storing a parsed version of `VCAP_SERVICES` and 
    VCAP_APPLICATION. 
    """

    @default_parser if Code.ensure_loaded?(Poison), do: JSONParser.Poison, else: nil

    @parser Application.get_env(:cf_env, :json_parser, @default_parser) || raise "No JSON parser specified in configuration, and default JSON adapter is unavailable. Please include a JSON parser. See hexdocs for details."
    
    @defaults Application.get_env(:cf_env, :default_services, %{})
    
    @spec start_link(term) :: {:ok, pid} | {:error, term}
    def start_link(_) do
        opts = [name: __MODULE__]
        GenServer.start_link(__MODULE__, [@defaults], opts)
    end

    @impl true    
    def init([default_services]) do
        vcap_services = System.get_env("VCAP_SERVICES") || "{}"
        vcap_application = System.get_env("VCAP_APPLICATION") || "{}"

        services = parse_services(default_services, vcap_services)
        app = parse_application(vcap_application)

        {:ok, %{ services: services, app: app } }
    end
  
    defp parse_services(default_services, vcap_services) do
        vcap_services
        |> @parser.decode!()
        |> Map.get("VCAP_SERVICES", %{})
        |> Map.get("user-provided", [])
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

    defp parse_application(vcap_application) do
        @parser.decode!(vcap_application) 
        |> Map.get("VCAP_APPLICATION", %{})
        
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
end
      
  