defmodule CFEnvTest do
  use ExUnit.Case
  doctest CFEnv

  setup do
    Application.put_env(:cf_env, :default_services, %{})
    CFEnv.Store.reparse()
  end

  test "gets the application" do
    assert CFEnv.get_application() == %{
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

  test "gets the services" do

    assert CFEnv.get_services == %{"cf-env-test" =>
      %{"credentials" => 
        %{"database" => "database","password" => "passw0rd", 
          "url" => "https://example.com/", "username" => "userid"
        }, 
        "label" => "user-provided",
        "name" => "cf-env-test",
        "syslog_drain_url" => "http://example.com/syslog",
        "tags" => []}
      }
  end

end
