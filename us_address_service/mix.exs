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
      extra_applications: [:logger, :plug_cowboy, :jason, :us_address],
      mod: {USAddressService.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4"},
      {:us_address, path: "../us_address"}
    ]
  end
end
