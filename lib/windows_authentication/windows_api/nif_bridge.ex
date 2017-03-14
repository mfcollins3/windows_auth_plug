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

defmodule Neudesic.WindowsAuthentication.WindowsAPI.NIFBridge do
  @moduledoc """
  `Neudesic.WindowsAuthentication.WindowsAPI.NIFBridge` implements the
  `Neudesic.WindowsAuthentication.WindowsAPI` behavior on Windows. This
  module will load a DLL containing code that will invoke the Windows API
  to obtain the user information given the user's Windows access token and
  to close the handle when the plug is done.
  """

  @behaviour Neudesic.WindowsAuthentication.WindowsAPI

  require Logger

  @on_load :load_nifs

  @doc """
  Loads the NIFs for the module.

  `load_nifs/0` only loads the NIFs when the application is running on a
  Windows machine.
  """
  def load_nifs do
    do_load_nifs(:os.type())
  end

  defp do_load_nifs({:win32, _}) do
    Logger.debug "The application is running on Windows. Loading the NIFs."
    path = :filename.join(:code.priv_dir(:neudesic_windows_auth_plug), "windows_authentication")
    :erlang.load_nif(path, 0)
  end
  
  defp do_load_nifs(_) do
    Logger.debug "The application is not running on Windows. The NIFs will not be loaded."
    :ok
  end

  def get_windows_username(_token_handle) do
    raise "get_windows_username/1 is only available on Windows"
  end

  def close_handle(_handle) do
    raise "get_windows_username/1 is only available on Windows"
  end
end
