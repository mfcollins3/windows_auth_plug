defmodule Neudesic.WindowsAuthenticationTest do
  use ExUnit.Case, async: true
  use Plug.Test

  doctest Neudesic.WindowsAuthentication
  
  test "stores the Windows user name in Conn.assigns" do
    conn =
      conn(:get, "/")
      |> put_req_header("x-iis-windowsauthtoken", "123")
      |> Neudesic.WindowsAuthentication.call({:win32, :nt})

    assert {"CORP", "michael.collins"} == conn.assigns.windows_user
  end

  test "windows_user is not set if the header is not present" do
    conn =
      conn(:get, "/")
      |> Neudesic.WindowsAuthentication.call({:win32, :nt})

    refute Map.has_key?(conn.assigns, :windows_user)
  end
end
