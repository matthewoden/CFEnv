defmodule CFEnv do
  @moduledoc """
  A small application for parsing and retrieving values from `VCAP_SERVICES`, 
  and `VCAP_APPLICATION.` 

  ## Installation

  Add the application to your dependancies:

  ```
  def deps do
  [
    {:cf_env, "~> 0.1.0"}
  ]
  ```

  And to your list of applications:

  ```
  def application do
    [
      # your other config...
      extra_applications: [
        :cf_env,
         # your other appliations...
      ]
    ]
  end
  ```

  CFEnv expects a json parser to be provided, and offers a `Poison`
  adapter by default. To use the default adapter, just add `{:poison, "~> 3.0"}` 
  to your list of dependancies.
  
  An alternate adapter can be configured as follows:

  ```
  config :cf_env,
    json_parser: YourApp.Adapter.Module.Name
  ```

  ## Usage

  There are two main modules: `CFEnv.Service` and `CFEnv.App`, and each
  module returns values from `VCAP_SERVICES`, and `VCAP_APPLICATION`, respectively.

  ### Example:

  Here's a quick example of grabbing the credentials for a service.

  ```
  CFEnv.Service.credentials("dynamo-db")

  # returns
  %{"database" => "dynamo", "accessKeyId" => "abcd",  
  "secretAccessKey" => "defg", "tableName" => "test-table" }
  ```

  Or grabbing the current application name.
  ```
  CFEnv.App.name()
  
  # returns
  "test_app"
  ```

  See each individual module for complete doecumentation.


  ### Default Services (and working locally)
  Default services bindings can be passed in as a map from configuration, 
  where each key is a string. You can provide reasonable defaults for
  local development this way.

  Accessing credentials is the most common use case for service bindings. If no 
  `credentials` key is present on the map,  then it is assumed that the
  entire map associated with the service are credentials.

  ```
  config :cf_env,
    default_services: %{ 
      "service_name" => %{ 
        "username" => "u5er",
        "password" => "pa$$w0rd"
      }
    }
  ```

  To add non-credential properties in as defaults, make sure a credentials key
  is present in your the default configuraion.
  ```
  config :cf_env,
    default_services: %{ 
      "service_name" => %{ 
        "tags" => [],
        "credentials" => %{
            "username" => "u5er",
            "password" => "pa$$w0rd"
        }
      }
    }
  ```




  ## Data Conversion

  On init, `VCAP_SERVICES`, and `VCAP_APPLICATION` are parsed from JSON.
  
  Each value is transformed into a map. If an alias key is present 
  on the credentials, the service will be mapped to use that name instead. 
  This is useful for updating the bindings for an application, without 
  having to implement a code change, or affect other services using this 
  binding.

  Every map created this way is merged back into the provided
  default service map, with parsed CF services overwriting defaults, 
  if any.

  Currently only `user-provided` services are supported.

  ### Example:

  The following list of services:

  ```
  {
    "user-provided": [
      {
        "name": "cf-env-test",
        "label": "user-provided",
        "tags": [],
        "credentials": {
            "database": "database",
            "password": "passw0rd",
            "url": "https://example.com/",
            "username": "userid"
        },
        "syslog_drain_url": "http://example.com/syslog"
      },
      {
        "name": "dynamo-db",
        "label": "user-provided",
        "tags": [],
        "credentials": {
          "alias": "alias-name",
          "database": "dynamo",
          "accessKeyId": "abcd",
          "secretAccessKey": "defg"
          "tableName": "test-table",
        },
        "syslog_drain_url": "http://example.com/syslog"
      }
    ]
  }
  ```

  is reduced to the following map:

  ```
  %{
      # using the name
      "cf-env-test" => %{
          "name" => "cf-env-test",
          "label" => "user-provided",
          "tags" => [],
          "credentials" => %{
              "database" => "database",
              "password" => "passw0rd",
              "url" => "https://example.com/",
              "username" => "userid"
          },
          "syslog_drain_url" => "http://example.com/syslog"
      },
      # used the alias
      "another-cf-env-test" => %{
          "name" => "another-cf-env-test",
          "label" => "user-provided",
          "tags" => [],
          "credentials" => %{
              "alias" => "alias-name",
              "database" => "dynamo",
              "accessKeyId" => "abcd",
              "secretAccessKey" => "defg"
              "tableName" => "test-table",
          },
          "syslog_drain_url": "http://example.com/syslog"
      }
  }
  ```
  """  

  @doc """
  Gets all services.
  """
  def get_services() do
    CFEnv.Store.get_services()
  end

  @doc """
  Gets the current application
  """
  def get_application() do
    CFEnv.Store.get_application()
  end
end