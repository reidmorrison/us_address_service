defmodule USAddressService.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias USAddressService.Endpoint

  @opts Endpoint.init([])

  @address %{"address" => "2811 Safe Harbor Drive", "city" => "Tampa", "state" => "FL", "zip" => "33618"}

  test "it returns pong" do
    # Create a test connection
    conn = conn(:get, "/ping")

    # Invoke the plug
    conn = Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "pong!"
  end

  test "it verifies an address using Get" do
    # Create a test connection
    conn = conn(:get, "/address?address=2811+Safe+Harbor+Drive&city=Tampa&state=FL&zip=33618")

    # Invoke the plug
    conn = Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200

    # Verify an address is returned
    address = Jason.decode!(conn.resp_body)
    assert address["address"] == "2811 Safe Harbor Dr"
    assert address["delivery_point"] == "33618453411"
  end

  test "it verifies an address using Get with garbage characters" do
    # Create a test connection
    conn = conn(:get, "/address?address=6729+%C3%83%C2%A0VE+E&suite&city=HOUSTON&state=TX&zip=77011")

    # Invoke the plug
    conn = Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200

    # Verify an address is returned
    verified = Jason.decode!(conn.resp_body)
    assert verified["address"] == "6729 Avenue E"
    assert verified["city"] == "Houston"
    assert verified["state"] == "TX"
    assert verified["zip"] == "77011"
    assert verified["delivery_point"] == "77011353529"
  end

  test "it verifies an address using Post" do
    # Create a test connection
    conn = conn(:post, "/address", @address)

    # Invoke the plug
    conn = Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200

    # Verify an address is returned
    address = Jason.decode!(conn.resp_body)
    assert address["address"] == "2811 Safe Harbor Dr"
    assert address["delivery_point"] == "33618453411"
  end

  test "it returns the address version info" do
    # Create a test connection
    conn = conn(:get, "/version")

    # Invoke the plug
    conn = Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200

    # Verify an address is returned
    version = Jason.decode!(conn.resp_body)
    assert version["initialize_status"] == "No error."
  end

  test "it returns 404 when no route matches" do
    # Create a test connection
    conn = conn(:get, "/fail")

    # Invoke the plug
    conn = Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 404
  end
end
