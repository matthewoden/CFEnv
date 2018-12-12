# CFEnv

A helper application for grabbing and parsing CloudFoundry Environment
Variables.

A small application for parsing and retrieving `VCAP_SERVICES`, and
`VCAP_APPLICATION.`

## API Preview

```elixir
> MyApp.Env.service_credentials("dynamo-db")
%{"database" => "dynamo", "accessKeyId" => "abcd", "secretAccessKey" => "defg",
  "tableName" => "test-table" }
```

Or grabbing the current application name.

```elixir
iex(1)> MyApp.Env.app_name()
"test_app"
```

See [the documentation](https://hexdocs.pm/cf_env/CFEnv.html) for other api
examples.

## Migration to 1.0.0

CFEnv is no longer an application, but a process started within your application, with functions created as a macro. All functionality is present, but CFEnv.Services and CFEnv.Application have been combined. See usage instructions below, and the `CFEnv` module.

## Usage

You'll need to add cf_env as a dependancy to your mix.exs file, along with a
module for parsing json. `CFEnv` supports `Poison` and `Jason` by
default, though custom JSON adapters can be provided. See `CFEnv.Adapters.JSON` for details.

### Dependancies

```elixir
  def deps do
      [
        {:cf_env, "~> 1.0"},
        {:jason, "~> 1.1"},

        # or, if you prefer poison
        {:poison, "~> 3.0"}
      ]
  end
```

Then, fetch your dependencies:

```bash
  $ mix deps.get
```

You'll need to create a module that represents your service bindings.

```elixir
defmodule MyApp.Env do
  use CFEnv,
    otp_app: :my_app,
    json_engine: Jason
    ...
```

Finally, add the process to your supervision tree:

```elixir
    # For Elixir v1.5 and later
    {MyApp.Env, [ default_bindings: %{} ]}

    # For Elixir v1.4 and earlier
    supervisor(MyApp.Env, [  default_bindings: %{}])
```

## Configuration

You can provide options as application config, or with runtime config. Runtime config always overrides application config.

### Application Config

```elixir
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

### Runtime Config

```elixir
options = [
  json_engine: Jason,
  default_services: %{
    "some_db" => %{
      "username" => System.get_env("TEST_USER"),
      "password" => System.get_env("TEST_PASSWORD")
    }
  }]

# explicit start
MyApp.Env.start_link(])

# supervisor start
children = [
  {MyApp.Env, [options]}
]


```

## Default Services

Working with VCAP_SERVICES can be a pain. Instead, default services bindings can be passed in as a map from configuration, where each key is a string. You can provide reasonable defaults for local development this way.

```elixir
config :cf_env,
  default_services:
    %{ "service_name" => %{
        "username" => "u5er",
        "password" => "pa$$w0rd"
      }
    }
```

## Data Conversion

On init, `VCAP_SERVICES` and `VCAP_APPLICATION` are parsed from JSON.

And each value is transformed into a map. If an alias key is present on the
credentials, the service will be mapped to use that name instead. This is useful
for updating the bindings for an application, without having to implement a code
change, or affect other services using this binding.

Every map created this way is merged back into the provided default service map,
with parsed CF services overwriting defaults, if any.

Currently only `user-provided` services are supported.

### Conversion Example:

The following list of services:

```json
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

```elixir
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
    # using the provided alias
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

## Local Development / Testing

Use the `.env` file to set up your local environment before testing.
