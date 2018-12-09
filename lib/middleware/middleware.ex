defmodule CFEnv.Middleware do
  @moduledoc """
  The adapter interface for pluggable service middleware.

  Your VCAP services might need to be parsed and transformed as part of startup,
  such as vault paths, or base64 decoding. Or maybe you want to derive services 
  maps to structs.

  There are two callbacks - `init` and `call`. 

  `init` is given the arguments from configuration, and a map of the current services.
  it should returns a tuple of {:ok, state}, which will be provided to the `call` callback.
  It's recommended to do any setup needed in `init`.

  ## Examples
  You can add a Middleware using the `plug` macro.

  Provide a module, and a list of options to be passed to the init callback.

  ```
  defmodule MyApp.Env do
    use CFEnv, otp_app: my_app

    # decode the credentials under "database" and "aws"
    plug CFEnv.Base64, services: ["database", "AWS"] 

  end
  ```

  """

  @typedoc "Service Name"
  @type service_name :: String.t()

  @typedoc "Service Value"
  @type service_value :: term()

  @typedoc "Map of Service Bindings"
  @type services :: map()

  @typedoc "State passed into every `call` callback"
  @type state :: term

  @typedoc "Initial values passed into Middleware's `init` callback"
  @type options :: [term]

  @doc """
  Initializes the processor. Any shared setup that needs to be done beforehand 
  should be done here.

  ## Examples

  Should return a tuple of either `{:ok, state}` or `{:error, reason}`.

  The state will be provided to the `call` callback.
  ``` 
  defmodule MyProcessor do

    def init(services, options) do
      services = Keyword.get(options, :services, [])

      {:ok, %{services: services}}
    end

    ...

  end
  ```
  """
  @callback init(services, []) :: {:ok, state} | {:error, term}

  @doc """
  Processes a key in the service bindings. 

  ## Examples
  Each processors iterates over every service concurrently. When a processor is 
  called, it only has access to the current service. 

  The return value should be a tuple, consisting of the service name, and the the service value.
  ``` 
  defmodule MyProcessor do
    
    def call({service_name, service_value} = service, state) do
      if service_name in state.services do
        {service_name, some_processing_function(service_value)}
      else
        service
      end
    end

    ...

  end
  ```
  """

  @callback call({service_name, service_value}, state) :: {service_name, service_value}
end
