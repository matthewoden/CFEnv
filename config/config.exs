use Mix.Config

config :cf_env, TestAppEnv, json_engine: Poison

config :cf_env, TestBadEnv, json_engine: nil
