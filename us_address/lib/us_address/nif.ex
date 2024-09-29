defmodule USAddress.Nif do
  @on_load :load_nif
  @app Mix.Project.config()[:app]

  def load_nif do
    unquote(@app)
    |> :code.priv_dir()
    |> :filename.join("md_address")
    |> :erlang.load_nif(0)
  end

  def init(_data_path), do: raise("NIF init/1 not implemented")
  def version(_handle), do: raise("NIF version/1 not implemented")
  def verify_c(_handle, _address_map), do: raise("NIF verify_c/2 not implemented")
  def verify(handle, address_map), do: verify_c(handle, cleanse_map(address_map))

  def cleanse_map(address_map) do
    Enum.into(
      Enum.map(
        address_map,
        fn {key, value} -> {key, cleanse(value)} end
      ),
      %{}
    )
  end

  def cleanse(nil), do: nil
  def cleanse(""), do: ""

  def cleanse(value) do
    value |> :unicode.characters_to_nfd_binary() |> String.replace(~r/[^A-z0-9\s]/, "")
  end
end
