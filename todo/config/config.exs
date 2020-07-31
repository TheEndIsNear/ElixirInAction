use Mix.Config

config :todo, port: 5454

import_config "#{Mix.env()}.exs"
