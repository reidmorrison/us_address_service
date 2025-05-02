defmodule USAddressService.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong!")
  end

  get "/address" do
    {status, body} = verify_address(conn.params)
    send_resp(conn, status, body)
  end

  post "/address" do
    {status, body} = verify_address(conn.body_params)
    send_resp(conn, status, body)
  end

  get "/version" do
    {status, body} = address_version()
    send_resp(conn, status, body)
  end

  defp verify_address(address) when is_map(address) do
    json = USAddress.verify(address) |> Jason.encode!()
    {200, json}
  end

  defp verify_address(_) do
    json = %{error: "Empty request / missing parameters"} |> Jason.encode!()
    {422, json}
  end

  defp address_version() do
    json = USAddress.version() |> Jason.encode!()
    {200, json}
  end

  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    message = %{error: "Invalid route."} |> Jason.encode!()
    send_resp(conn, 404, message)
  end
end
