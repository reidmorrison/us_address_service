defmodule USAddress.Server do
  alias USAddress.Nif

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(_) do
    Application.fetch_env!(:us_address, :data_path)
    |> Nif.init()
  end

  def handle_call({:verify, address_map}, _from, us_address) do
    result = us_address
             |> USAddress.Nif.verify(address_map)
    {:reply, result, us_address}
  end

  def handle_call({:version}, _from, us_address) do
    result = USAddress.Nif.version(us_address)
    {:reply, result, us_address}
  end
end
