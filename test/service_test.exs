defmodule CFEnv.ServiceTest do
    use ExUnit.Case, async: true

    alias CFEnv.Service
    doctest Service

    test "get returns an entire service" do
        assert Service.get("cf-env-test") == %{
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

    test "get property returns a property off of a named service" do
        assert Service.get_property(
            "cf-env-test", 
            "syslog_drain_url") == "http://example.com/syslog"
    end

    test "name returns the name property for a service" do
        assert Service.name("cf-env-test") == "cf-env-test"
    end

    test "plan returns the plan property for a service" do
        assert Service.plan("cf-env-test") == nil
    end

    test "tags returns the tag property for a service" do
        assert Service.tags("cf-env-test") ==  []
    end

    test "credentials returns the credentials property for a service" do
        assert Service.credentials("cf-env-test") == %{
            "database" => "database",
            "password" => "passw0rd", 
            "url" => "https://example.com/", 
            "username" => "userid"
        }
    end
end