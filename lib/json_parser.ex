defmodule CFEnv.Adapters.JSON do
  @type parsed ::
          nil
          | true
          | false
          | list
          | float
          | integer
          | String.t()
          | map

  @moduledoc """
  A basic adapter for a JSON parser. Returns parsed json, or fails.
  """

  @doc """
  Decodes JSON into a `CFEnv.Adapters.JSON.parsed` type.
  """
  @callback decode!(iodata, Keyword.t()) :: parsed | no_return
end
