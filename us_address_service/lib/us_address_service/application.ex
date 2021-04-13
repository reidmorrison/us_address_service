defmodule USAddressService.Application do
  @moduledoc "OTP application specification for USAddressService"

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: USAddressService.Endpoint,
        options: [
          port: Application.get_env(:us_address_service, :port),
          compress: true,
          transport_options: [
            num_acceptors: Application.get_env(:us_address, :pool_size)
          ]
        ]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: USAddressService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
