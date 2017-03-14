# Copyright 2017 Neudesic, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule Neudesic.WindowsAuthentication do
  @moduledoc """
  `Neudesic.WindowsAuthentication` implements a plug that will look for
  the `X-IIS-WindowsAuthToken` HTTP header in the request, and if found,
  will obtain the Windows domain user name for the authenticated user.
  This plug is intended to be used for enterprise intranet web applications
  that are built using the Phoenix framework and are deployed to a Windows
  server. The Phoenix web application will use IIS as a proxy and the
  [HttpPlatformHandler](https://www.iis.net/downloads/microsoft/httpplatformhandler)
  add-on to run the Phoenix web application and forward requests from IIS
  to the Phoenix application.

  `Neudesic.WindowsAuthentication` uses NIFs written in C to call Win32 APIs
  in order to lookup the domain name and user name for the user that was
  authenticated using integrated Windows authentication. The domain name
  and user name for the Windows user will be added to the
  `Conn.assigns` map.

  `Neudesic.WindowsAuthentication` is safe to use in all hosting environments.
  `Neudesic.WindowsAuthentication` will only process requests when the web
  application is being run on Windows. The NIFs will only be called if the
  `X-IIS-WindowsAuthToken` is present in the request. You can use the
  `Neudesic.WindowsAuthentication` plug when running from the command line,
  but Windows authentication and processing the request header will not
  occur unless the web application is running as a child process of IIS.
  """

  import Plug.Conn

  require Logger

  @windows_api Application.get_env(:neudesic_windows_auth_plug, :windows_api)

  @doc """
  Initializes the plug.
  """
  def init(%{:os_type => os_type}), do: os_type
  def init(_options), do: :os.type()

  @doc """
  Looks for the `X-IIS-WindowsAuthToken` HTTP header, and if present,
  stores the domain name and user name for the authenticated user in the
  `Conn.assigns` map using the `:windows_user` key.
  """
  def call(conn, os_type) do
    Logger.debug "Windows authentication plug called"
    do_windows_authentication(conn, os_type)
  end

  defp do_windows_authentication(conn, {:win32, _}) do
    do_process_windows_auth_token_header(conn, get_req_header(conn, "x-iis-windowsauthtoken"))
  end

  defp do_windows_authentication(conn, _) do
    Logger.debug "The Windows authentication plug is not running on Windows; skipping"
    conn
  end

  defp do_process_windows_auth_token_header(conn, [token_string]) do
    Logger.debug "Found the X-IIS-WindowsAuthToken HTTP header"
    Logger.debug fn -> "Windows authentication token = #{token_string}" end

    token_handle = String.to_integer(token_string, 16)
    
    Logger.debug "Getting the Windows user name"
    {:ok, windows_user} = @windows_api.get_windows_username(token_handle)
    Logger.debug fn ->
      {domain, username} = windows_user
      "Windows user = #{domain}\\#{username}"
    end
    
    Logger.debug "Closing the Windows authentication token handle"
    @windows_api.close_handle(token_handle)
    
    Logger.debug "Saving the Windows user name to Conn.assigns"
    assign(conn, :windows_user, windows_user)
  end

  defp do_process_windows_auth_token_header(conn, []) do
    Logger.debug "The X-IIS-WindowsAuthToken HTTP header was not present on the request"
    conn
  end
end