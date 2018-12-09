defmodule CFEnv.Base64Test do
  use ExUnit.Case, async: true

  def data() do
    %{
      "test" => %{
        "credentials" => %{
          "key" => Base.encode64("value1"),
          "another_key" => %{
            "key" => Base.encode64("value2.1"),
            "whatever" => Base.encode64("value2.2")
          },
          "another_key1" => %{
            "another_key2" => %{"key" => Base.encode64("value3")},
            "another_key3" => %{
              "another_key4" => %{
                "another_key5" => %{
                  "another_key6" => %{
                    "key" => Base.encode64("value4")
                  }
                }
              }
            }
          }
        }
      }
    }
  end 

  test "it collects keys to transform" do
    {:ok, state} = CFEnv.Middleware.Base64.init(data(), services: ["test", "test2"])
    assert state.services == ["test", "test2"]
  end

  test "it transforms a service, decoding where possible" do
    {:ok, state} = CFEnv.Middleware.Base64.init(data(), services: ["test"])
    {name, service} = CFEnv.Middleware.Base64.call({"test", data()["test"]}, state)
    assert name == "test"
    assert service ==  %{
        "credentials" => %{
          "key" => "value1",
          "another_key" => %{
            "key" => "value2.1",
            "whatever" => "value2.2"
          },
          "another_key1" => %{
            "another_key2" => %{"key" => "value3"},
            "another_key3" => %{
              "another_key4" => %{
                "another_key5" => %{
                  "another_key6" => %{
                    "key" => "value4"
                  }
                }
              }
            }
          }
        }
      }
  end
end
