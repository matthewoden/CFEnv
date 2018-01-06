defmodule CFEnv.StoreTest do
    use ExUnit.Case

    test "reparse services updates the service configuration based on the environment" do
        service = %{ 
            "credentials" =>  %{
                "username" => "new_u5er",
                "password" => "pa$$w0rd"
            }
        }
        Application.put_env(:cf_env, :default_services, %{ "service_name" => service })

        CFEnv.Store.reparse()
        assert CFEnv.Store.get_service("service_name") == service

    end

    test "it parses default services with credentials" do
        service = %{ 
            "credentials" =>  %{
                "username" => "u5er",
                "password" => "pa$$w0rd"
            }
        }

        Application.put_env(:cf_env, :default_services, %{ "service_name" => service })
        CFEnv.Store.reparse()

        assert CFEnv.Store.get_service("service_name") == service
    end

    test "it parses default services without a credentials property" do
        service = %{
            "username" => "u5er",
            "password" => "pa$$wArd"
        }

        Application.put_env(:cf_env, :default_services, %{ "service_name" => service })
        CFEnv.Store.reparse()

        assert CFEnv.Store.get_service("service_name") == %{
            "credentials" =>  %{
                "username" => "u5er",
                "password" => "pa$$wArd"
            }
        }
        
    end



    

end