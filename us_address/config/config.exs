# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

config :us_address, data_path: "/opt/data"

import_config "#{config_env()}.exs"
