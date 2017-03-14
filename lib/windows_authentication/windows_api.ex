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

defmodule Neudesic.WindowsAuthentication.WindowsAPI do
  @moduledoc """
  `Neudesic.WindowsAuthentication.WindowsAPI` defines a behavior with
  functions that will invoke the Win32 API to retrieve information about
  a user that has been authenticated using Windows authentication for an
  HTTP request.
  """

  @doc """
  Given a Windows user token handle, `get_windows_username` will use the
  Win32 API to obtain the name of the Windows domain that the user was
  authenticated against and the user name for the authenticated user.
  """
  @callback get_windows_username(token_handle :: number) :: 
    {:ok, {domain :: String.t, username :: String.t}} |
    {:error, :invalid_token_handle} |
    {:error, {:win32_error, number}}

  @doc """
  Closes the Win32 handle.
  """
  @callback close_handle(handle :: number) :: 
    :ok |
    {:error, :invalid_token_handle} |
    {:error, {:win32_error, number}}
end
