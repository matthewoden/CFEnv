defmodule CFEnv.Application do
    @doc """
    Starts the application. (Be sure to list `:cf_env` in your list
    of applications.)
    """
    def start(_type, _args) do
        children = [
          {CFEnv.Store, []}
        ]
  
        opts = [strategy: :one_for_one, name: CFEnv.Supervisor]
        Supervisor.start_link(children, opts)
      end
end