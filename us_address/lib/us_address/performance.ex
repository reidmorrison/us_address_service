defmodule USAddress.Performance do
  @timeout 10_000

  def start(address, count) do
    time = seconds(fn -> run(address, count) end)
    IO.puts("Completed in #{time} seconds.")
  end

  defp run(address, count) do
    1..count
    |> Enum.map(fn _-> async_call(address) end)
    |> Enum.each(fn task -> await_and_inspect(task) end)
  end

  defp async_call(address) do
    Task.async(fn -> USAddress.verify(address) end)
  end

  defp await_and_inspect(task) do
    time = seconds(fn -> Task.await(task, @timeout) end)
    if time > 0.1, do: IO.inspect(time)
#    IO.inspect(:poolboy.status(USAddress.Application.pool_name()))
  end

  # Microseconds
  defp measure(function) do
    function
    |> :timer.tc
    |> elem(0)
  end

  defp seconds(function) do
    measure(function)
    |> Kernel./(1_000_000)
  end
end
