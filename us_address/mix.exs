defmodule USAddress.MixProject do
  use Mix.Project

  def project do
    [
      app: :us_address,
      compilers: [:make] ++ Mix.compilers,
      aliases: aliases(),
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {USAddress.Application, []}
    ]
  end

  defp deps do
    [
      {:poolboy, "~> 1.5"}
    ]
  end

  defp aliases() do
    [clean: ["clean", "clean.make"]]
  end
end

defmodule Mix.Tasks.Compile.Make do
  @doc "Compiles helper in src"

  def run(_) do
    {result, _error_code} = System.cmd("make", [], stderr_to_stdout: true)
    Mix.shell.info result

    :ok
  end
end

defmodule Mix.Tasks.Clean.Make do
  @doc "Cleans helper in src"

  def run(_) do
    {result, _error_code} = System.cmd("make", ["clean"], stderr_to_stdout: true)
    Mix.shell.info result

    :ok
  end
end
