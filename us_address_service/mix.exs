defmodule USAddressService.MixProject do
  use Mix.Project

  def project do
    [
      app: :us_address_service,
      version: "0.1.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :plug_cowboy, :jason, :logger_json, :us_address],
      mod: {USAddressService.Application, []}
    ]
  end

  defp deps do
    [
      {:bugsnag, "~> 2.0.0", only: :prod},
      {:plug_cowboy, "~> 2.1"},
      {:logger_json, "~> 4.0"},
      {:jason, "~> 1.2"},
      {:us_address, path: "../us_address"}
    ]
  end
end
