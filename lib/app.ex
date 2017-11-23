defmodule CFEnv.App do
    
    @moduledoc """
    Gets values from the parsed `VCAP_APPLICATION` environment variable.

    For a list of what these properties are, see:
    [VCAP_APPLICATION Details in the cloudfoundry docs.](https://docs.cloudfoundry.org/devguide/deploy-apps/environment-variable.html#VCAP-APPLICATION)

    Currently supports values available to CloudFoundry diego, but older
    properties can be fetched with the `CFEnv.App.get_property` function.
    """

    @doc """
    Gets the entire application.
    """
    @spec get() :: term
    def get(), do: CFEnv.Store.get_application()

    @doc """
    Gets the value for a property from the current VCAP_APPLICATION by 
    key. You can grab legacy and depreciated properties with this.
    """
    @spec get_property(String.t) :: term
    def get_property(property), do: CFEnv.Store.get_application(property)
    
    @doc """
    Gets the value of the `application_id` property for the current application.
    """
    @spec id() :: String.t | nil
    def id, do: get_property("application_id")
    
    @doc """
    Gets the value of the `application_name` property for the current application.
    """
    @spec name() :: String.t | nil
    def name, do: get_property("application_name")

    @doc """
    Gets the value of the `application_uris` property for the current application.
    """
    @spec uris() :: [String.t] | nil
    def uris, do: get_property("application_uris")
    

    @doc """
    Gets the value of the `application_version` property for the current application.
    """
    @spec version() :: String.t | nil
    def version, do: get_property("application_version")

    @doc """
    Gets the value of the `cf_api` property for the current application.
    """
    @spec cf_api() :: String.t
    def cf_api, do: get_property("cf_api")
    
    @doc """
    Gets the value of the `limits` property for the current application.
    """
    @spec limits() :: term
    def limits, do: get_property("limits")


    @doc """
    Gets the value of the `space_id` property for the current application.
    """
    @spec space_id() :: term
    def space_id, do: get_property("space_id")
    
    @doc """
    Gets the value of the `space_name` property for the current application.
    """
    @spec space_name() :: term
    def space_name, do: get_property("space_name")
    
    @doc """
    Returns the value of the `start` property for the current application.
    """
    @spec start() :: term
    def start, do: get_property("start")

end