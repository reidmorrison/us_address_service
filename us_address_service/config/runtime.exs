import Config

config :us_address, data_path: "/opt/data"

config :logger, :console, level: :debug

config :us_address, pool_size: String.to_integer(System.get_env("ADDRESS_POOL_SIZE") || "300")

config :us_address,
  overflow_size:
    String.to_integer(System.get_env("ADDRESS_OVERFLOW_SIZE") || System.get_env("ADDRESS_POOL_SIZE") || "0")

config :us_address_service, port: String.to_integer(System.get_env("PORT") || "8080")
