defmodule USAddress.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      :poolboy.child_spec(pool_name(), poolboy_config())
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html for other strategies and supported options
    opts = [
      name: USAddress.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, opts)
  end

  def pool_name do
    :us_address_pool
  end

  defp poolboy_config do
    [
      {:name, {:local, pool_name()}},
      {:worker_module, USAddress.Server},
      {:size, Application.get_env(:us_address, :pool_size, 10)},
      {:max_overflow, Application.get_env(:us_address, :overflow_size, 0)}
    ]
  end
end
