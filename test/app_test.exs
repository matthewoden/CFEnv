defmodule CFEnv.AppTest do
    use ExUnit.Case, async: true

    doctest CFEnv.App

    test "get returns the whole application" do
        assert CFEnv.App.get() == %{
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

    test "get_property returns a property on the application" do
        assert CFEnv.App.get_property("name") ==  "my-app"
    end

    test "id gets the app id" do
        assert CFEnv.App.id == "fa05c1a9-0fc1-4fbd-bae1-139850dec7a3"
    end

    test "name gets the app name" do
        assert CFEnv.App.name == "my-app"
    end

    test "uri returns the app uri" do
        assert CFEnv.App.uris == ["my-app.192.0.2.34.xip.io"]
    end

    test "version returns the app version" do
        assert CFEnv.App.version == "fb8fbcc6-8d58-479e-bcc7-3b4ce5a7f0ca"
    end

    test "cf_api returns the cf_api" do
        assert CFEnv.App.cf_api == "https://api.example.com"
    end

    test "limits returns the apps limits" do
        assert CFEnv.App.limits == %{"disk" => 1024, "fds" => 16384, "mem" => 256}
    end

    test "space_id returns the space id" do
        assert CFEnv.App.space_id == "06450c72-4669-4dc6-8096-45f9777db68a"
    end

    test "space name returns the space name" do
        assert CFEnv.App.space_name == "my-space"
    end

    test "start returns the start timestamp" do
        assert CFEnv.App.start == "2013-08-12 00:05:29+0000"
    end


end