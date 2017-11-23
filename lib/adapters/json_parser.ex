defmodule CFEnv.Adapters.JSONParser do
    @type parsed ::
        nil |
        true |
        false |
        list |
        float |
        integer |
        String.t |
        map

    @moduledoc """
    A basic adapter for a JSON parser. Returns parsed json, or fails.
    """

    @doc """
    Decodes JSON into a `CFEnv.Adapters.JSONParser.parsed` type.
    """
    @callback decode!(iodata, Keyword.t) :: parsed | no_return
end

if Code.ensure_loaded?(Poison) do
    defmodule CFEnv.Adapters.JSONParser.Poison do

        @moduledoc """
        A JSON decoder for CFEnv. 

        To use, add Poison to your mix.exs dependencies:

            def deps do
                [{:poison, "~> 3.0"}]
            end

        Then, update your dependencies:

            $ mix deps.get

        The adapter will automatically be picked up and used by CFEnv,
        unless explicitly configured for another adapter. If you want 
        to manually add this parser to the configuration, simply
        include the following:

            config :cf_env
                json_parser: CFEnv.Adapters.JSONParser.Poison
        """
        @behaviour CFEnv.Adapters.JSONParser

        @impl true
        @doc """
        Decodes JSON into a `CFEnv.Adapters.JSONParser.parsed` type.
        """
        def decode!(iodata, options \\ []) do
            Poison.decode!(iodata, options)
        end
    end
end