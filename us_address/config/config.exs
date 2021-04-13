# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :us_address, data_path: "/opt/data"

import_config "#{Mix.env()}.exs"
