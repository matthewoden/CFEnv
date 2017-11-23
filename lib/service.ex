defmodule CFEnv.Service do
    @moduledoc """
    Grabs values from the parsed `VCAP_SERVICES`. currently only
    user-provided services are provided.
    """

    @doc """
    Get the entire service, as a map.
    """
    @spec get(String.t) :: term
    def get(name), do: CFEnv.Store.get_service(name)

    @doc """
    Gets the value of a proprty for a service.
    """
    @spec get_property(String.t, String.t) :: term
    def get_property(name, property), do: CFEnv.Store.get_service(name, property)

    @doc """
    Gets the `label` property for a service.
    """
    @spec label(String.t) :: String.t | nil
    def label(name), do: get_property(name, "label")
    
    @doc """
    Gets the `name` property for a service. (Given that tne name is requires, 
    this is only useful when using an alias.)
    """
    @spec name(String.t) :: String.t | nil
    def name(name), do: get_property(name, "name")
    
    @doc """
    Gets the `plan` property for a service.
    """
    @spec plan(String.t) :: String.t | nil
    def plan(name), do: get_property(name, "plan")

    @doc """
    Gets the `tags` property for a service.
    """
    @spec tags(String.t) :: [String.t]        
    def tags(name), do: get_property(name, "tags") || []

    @doc """
    Gets the `credentials` property for a service.
    """
    @spec credentials(String.t) :: map            
    def credentials(name), do: get_property(name, "credentials") || %{}
    
end