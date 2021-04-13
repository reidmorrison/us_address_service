defmodule NifTest do
  alias USAddress.Nif

  use ExUnit.Case
  doctest USAddress.Nif

  test "init :ok" do
    {:ok, resource} = Nif.init(Application.fetch_env!(:us_address, :data_path))
    assert resource
  end

  test "init :error" do
    {:error, error} = Nif.init("bad_path")
    assert "Could not open the mdAddr.nat or mdAddr.str file. No such file or directory" == error
  end

  test "version" do
    {:ok, resource} = Nif.init(Application.fetch_env!(:us_address, :data_path))
    result = Nif.version(resource)
    assert result[:build_number]
    assert result[:database_date]
    assert result[:expiration_date]
    assert result[:initialize_status]
    assert result[:license_expiration_date]
  end

  test "verify" do
    {:ok, resource} = Nif.init(Application.fetch_env!(:us_address, :data_path))
    address = %{"address" => "2811 Safe Harbor Drive", "city" => "Tampa", "state" => "FL", "zip" => "33618"}
    address = Nif.verify(resource, address)
    assert address[:address] == "2811 Safe Harbor Dr"
    assert address[:delivery_point] == "33618453411"
    assert address[:time_zone] == "Eastern Time"
  end

  test "cleanse_map with empty strings" do
    address = %{"address" => "2811 Safe Harbor Drive", "city" => "Tampa", "state" => "FL", "zip" => ""}
    assert address == Nif.cleanse_map(address)
  end

  test "cleanse_map with nil values" do
    address = %{"address" => "2811 Safe Harbor Drive", "city" => "Tampa", "state" => "FL", "zip" => nil}
    assert address == Nif.cleanse_map(address)
  end

  test "cleanse_map with utf8 values" do
    address = %{"address" => "2004 SAN SEBASTIáN CT", "city" => "HOUSTON", "state" => "TX", "zip" => "77058"}
    expected = %{"address" => "2004 SAN SEBASTIaN CT", "city" => "HOUSTON", "state" => "TX", "zip" => "77058"}
    assert expected == Nif.cleanse_map(address)
  end

  test "cleanse nil string" do
    assert nil == Nif.cleanse(nil)
  end

  test "cleanse empty string" do
    assert "" == Nif.cleanse("")
  end

  test "cleanse regular string" do
    assert "ABCDefghi1234567890 " == Nif.cleanse("ABCDefghi1234567890 ")
  end

  test "cleanse utf8 equivalents" do
    assert "2004 SAN SEBASTIaN CT" == Nif.cleanse("2004 SAN SEBASTIáN CT")
  end

  test "cleanse utf8 into ascii only" do
    assert "6729 AVe E" == Nif.cleanse("6729 Ã Ve E")
  end
end
