defmodule TestEnv do
  use CFEnv, otp_app: :cf_env
end

# app env specified
defmodule TestAppEnv do
  use CFEnv, otp_app: :cf_env
end

# app env specified
defmodule TestModuleEnv do
  use CFEnv, otp_app: :cf_env, json_engine: Poison
end

# no json parser
defmodule TestBadEnv do
  use CFEnv, otp_app: :cf_env
end

defmodule TestEnvMiddleware do
  use CFEnv, otp_app: :cf_env

  plug(CFEnv.Middleware.Base64, services: ["encoded_service"])
end
