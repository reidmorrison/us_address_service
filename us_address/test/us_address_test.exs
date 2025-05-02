defmodule PostalAddressTest do
  use ExUnit.Case
  doctest USAddress

  test "verify" do
    address = %{"address" => "2811 Safe Harbor Drive", "city" => "Tampa", "state" => "FL", "zip" => "33618"}
    verified = USAddress.verify(address)

    assert verified[:address] == "2811 Safe Harbor Dr"
    assert verified[:city] == "Tampa"
    assert verified[:state] == "FL"
    assert verified[:zip] == "33618"
  end

  test "verify with utf-8" do
    address = %{"address" => "2811 Sëbastián Drîve", "city" => "Tâmpá", "state" => "FĹ", "zip" => "33618"}
    verified = USAddress.verify(address)

    assert verified[:address] == "2811 Sebastian Drive"
    assert verified[:city] == "Tampa"
    assert verified[:state] == "FL"
    assert verified[:zip] == "33618"
  end

  test "verify non utf-8" do
    address = %{"address" => "2811 Safe Harbor Drive", "city" => "Tampa", "state" => "FL", "zip" => "33618"}
    verified = USAddress.verify(address)

    assert verified[:address] == "2811 Safe Harbor Dr"
    assert verified[:city] == "Tampa"
    assert verified[:state] == "FL"
    assert verified[:zip] == "33618"
  end

  test "verify with empty strings" do
    address = %{"address" => "2811 Safe Harbor Drive", "city" => "Tampa", "state" => "FL", "zip" => ""}
    verified = USAddress.verify(address)

    assert verified[:address] == "2811 Safe Harbor Dr"
    assert verified[:city] == "Tampa"
    assert verified[:state] == "FL"
    assert verified[:zip] == "33618"
    assert verified[:delivery_point] == "33618453411"
  end

  test "verify with nil values" do
    address = %{"address" => "2811 Safe Harbor Drive", "city" => "Tampa", "state" => "FL", "zip" => nil}
    verified = USAddress.verify(address)

    assert verified[:address] == "2811 Safe Harbor Dr"
    assert verified[:city] == "Tampa"
    assert verified[:state] == "FL"
    assert verified[:zip] == "33618"
    assert verified[:delivery_point] == "33618453411"
  end

  test "verify with utf8 values" do
    address = %{"address" => "2004 SAN SEBASTIáN CT", "city" => "HOUSTON", "state" => "TX", "zip" => "77058"}
    verified = USAddress.verify(address)

    assert verified[:address] == "2004 San Sebastian Ct"
    assert verified[:city] == "Houston"
    assert verified[:state] == "TX"
    assert verified[:zip] == "77058"
    assert verified[:delivery_point] == "77058361004"
  end

  test "verify with more utf8 values" do
    address = %{"address" => "6729 Ã VE E", "city" => "HOUSTON", "state" => "TX", "suite" => nil, "zip" => "77011"}
    verified = USAddress.verify(address)

    assert verified[:address] == "6729 Avenue E"
    assert verified[:city] == "Houston"
    assert verified[:state] == "TX"
    assert verified[:zip] == "77011"
    assert verified[:delivery_point] == "77011353529"
  end

  test "verify with no keys" do
    address = %{}
    verified = USAddress.verify(address)

    assert verified[:address] == ""
    assert verified[:city] == ""
    assert verified[:state] == ""
    assert verified[:zip] == ""
    assert verified[:delivery_point] == ""
  end

  test "version" do
    result = USAddress.version()
    assert result[:build_number]
    assert result[:database_date]
    assert result[:expiration_date]
    assert result[:initialize_status]
    assert result[:license_expiration_date]
  end

  test "not using a demo license" do
    version = USAddress.version()
    refute version[:build_number] =~ " DEMO"
  end
end
