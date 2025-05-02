defmodule USAddress do
  @timeout 10_000

  def verify(address_map) do
    :poolboy.transaction(
      USAddress.Application.pool_name(),
      fn pid -> GenServer.call(pid, {:verify, address_map}) end,
      @timeout
    )
  end

  def version() do
    :poolboy.transaction(
      USAddress.Application.pool_name(),
      fn pid -> GenServer.call(pid, {:version}) end,
      @timeout
    )
  end
end
