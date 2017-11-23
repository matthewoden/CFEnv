# CFEnv

A helper application for grabbing and parsing CloudFoundry Environment
Variables.

A small application for parsing and retrieving `VCAP_SERVICES`, and
`VCAP_APPLICATION.`

Expects a json parser to be provided, and comes with a `Poison` adapter by
default.

To use, add Poison to your mix.exs dependencies:

```elixir
  def deps do
      [{:poison, "~> 3.0"}]
  end
```

Then, update your dependencies:

```bash
  $ mix deps.get
```

The adapter will automatically be picked up and used by CFEnv, unless explicitly
configured for another adapter. If you want to manually add this parser to the
configuration, simply include the following:

    config :cf_env
        json_parser: CFEnv.Adapters.JSONParser.Poison

## Using CFEnv

There are two main modules: `CFEnv.Service` and `CFEnv.App`, and each module
returns values from VCAP_SERVICES, and VCAP_APPLICATION, respectively.

### Usage Example

Here's a quick example of grabbing the credentials for a service.

```elixir
CFEnv.Service.credentials("dynamo-db")

# returns

%{"database" => "dynamo", "accessKeyId" => "abcd", "secretAccessKey" => "defg",
"tableName" => "test-table" }
```

Or grabbing the current application name.

```elixir
CFEnv.App.name()

# returns

"test_app"
```

### Default Services (and working locally)

Default services bindings can be passed in as a map from configuration, where
each key is a string. You can provide reasonable defaults for local development
this way.

```elixir
config :cf_env,
  default_services:
    %{ "service_name" =>
      %{ "credentials" =>
        %{ "username" => "u5er",
          "password" => "pa$$w0rd"
        }
      }
    }
```

## Data Conversion

On init, `VCAP_SERVICES` and `VCAP_APPLUIATION` are parsed from JSON.

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

## Installation

The package can be installed by adding `cf_env` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:cf_env, "~> 0.1.0"},
    {:poison, "~> 3.0"} # optional, used for the Posion JSON parsing adapter
  ]
end
```

Documentation can be generated with
[ExDoc](https://github.com/elixir-lang/ex_doc) and published on
[HexDocs](https://hexdocs.pm). Once published, the docs can be found at
[https://hexdocs.pm/cloudfoundry_services](https://hexdocs.pm/cloudfoundry_services).
