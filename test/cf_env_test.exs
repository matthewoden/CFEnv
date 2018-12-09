defmodule CFEnvTest do
  use ExUnit.Case, async: true

  setup do
    TestEnv.start_link(
      default_services: %{
        "service_with_credential_key" => %{
          "credentials" => %{
            "username" => "u5er",
            "password" => "pa$$w0rd"
          }
        },
        "service_without_credential_key" => %{
          "username" => "u5er",
          "password" => "pa$$wArd"
        }
      }
    )

    :ok
  end

  describe "parsing env var" do
    test "parses the application" do
      assert TestEnv.app() == %{
               "name" => "my-app",
               "users" => nil,
               "application_name" => "my-app",
               "application_uris" => ["my-app.192.0.2.34.xip.io"],
               "application_version" => "fb8fbcc6-8d58-479e-bcc7-3b4ce5a7f0ca",
               "limits" => %{"disk" => 1024, "fds" => 16384, "mem" => 256},
               "uris" => ["my-app.192.0.2.34.xip.io"],
               "version" => "fb8fbcc6-8d58-479e-bcc7-3b4ce5a7f0ca",
               "application_id" => "fa05c1a9-0fc1-4fbd-bae1-139850dec7a3",
               "cf_api" => "https://api.example.com",
               "space_id" => "06450c72-4669-4dc6-8096-45f9777db68a",
               "space_name" => "my-space",
               "start" => "2013-08-12 00:05:29+0000"
             }
    end

    test "parses the services" do
      assert TestEnv.services() == %{
               "cf-env-test" => %{
                 "credentials" => %{
                   "database" => "database",
                   "password" => "passw0rd",
                   "url" => "https://example.com/",
                   "username" => "userid"
                 },
                 "label" => "user-provided",
                 "name" => "cf-env-test",
                 "syslog_drain_url" => "http://example.com/syslog",
                 "tags" => []
               },
               "service_with_credential_key" => %{
                 "credentials" => %{"password" => "pa$$w0rd", "username" => "u5er"}
               },
               "service_without_credential_key" => %{
                 "credentials" => %{"password" => "pa$$wArd", "username" => "u5er"}
               }
             }
    end
  end

  describe "services" do
    test "service returns an entire service" do
      assert TestEnv.service("cf-env-test") == %{
               "credentials" => %{
                 "database" => "database",
                 "password" => "passw0rd",
                 "url" => "https://example.com/",
                 "username" => "userid"
               },
               "label" => "user-provided",
               "name" => "cf-env-test",
               "syslog_drain_url" => "http://example.com/syslog",
               "tags" => []
             }
    end

    test "service_name returns the name property for a service" do
      assert TestEnv.service_name("cf-env-test") == "cf-env-test"
    end

    test "service_plan returns the plan property for a service" do
      assert TestEnv.service_plan("cf-env-test") == nil
    end

    test "service_tags returns the tag property for a service" do
      assert TestEnv.service_tags("cf-env-test") == []
    end

    test "service_credentials returns the credentials property for a service" do
      assert TestEnv.service_credentials("cf-env-test") == %{
               "database" => "database",
               "password" => "passw0rd",
               "url" => "https://example.com/",
               "username" => "userid"
             }
    end
  end

  describe "application" do
    test "id gets the app id" do
      assert TestEnv.app_id() == "fa05c1a9-0fc1-4fbd-bae1-139850dec7a3"
    end

    test "name gets the app name" do
      assert TestEnv.app_name() == "my-app"
    end

    test "uri returns the app uri" do
      assert TestEnv.app_uris() == ["my-app.192.0.2.34.xip.io"]
    end

    test "version returns the app version" do
      assert TestEnv.app_version() == "fb8fbcc6-8d58-479e-bcc7-3b4ce5a7f0ca"
    end

    test "cf_api returns the cf_api" do
      assert TestEnv.app_cf_api() == "https://api.example.com"
    end

    test "limits returns the apps limits" do
      assert TestEnv.app_limits() == %{"disk" => 1024, "fds" => 16384, "mem" => 256}
    end

    test "space_id returns the space id" do
      assert TestEnv.app_space_id() == "06450c72-4669-4dc6-8096-45f9777db68a"
    end

    test "space name returns the space name" do
      assert TestEnv.app_space_name() == "my-space"
    end

    test "start returns the start timestamp" do
      assert TestEnv.app_start() == "2013-08-12 00:05:29+0000"
    end
  end

  describe "config" do
    test "throws if no json engine is available/supplied" do
      Process.flag(:trap_exit, true)

      {:error, reason} = TestBadEnv.start_link([])
      assert reason == "No JSON engine specified. Cannot decode JSON"
      Process.flag(:trap_exit, false)
    end

    test "pulls from the app env when specified" do
      TestAppEnv.start_link([])
      assert Poison == TestAppEnv.config() |> Keyword.get(:json_engine)
    end
  end

  describe "middleware" do
    test "runs processes pluggable middleware" do
      TestEnvMiddleware.start_link(
        default_services: %{
          "encoded_service" => %{
            "key" => Base.encode64("value")
          }
        }
      )

      assert TestEnvMiddleware.service_credentials("encoded_service") == %{
        "key" => "value"
      }
    end
  end
end
