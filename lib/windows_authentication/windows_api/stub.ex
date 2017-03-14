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

defmodule Neudesic.WindowsAuthentication.WindowsAPI.Stub do
  @moduledoc """
  `Neudesic.WindowsAuthentication.WindowsAPI.Stub` is used during unit testing
  the plug.
  """

  @behaviour Neudesic.WindowsAuthentication.WindowsAPI

  def get_windows_username(_token_handle) do
    {:ok, {"CORP", "michael.collins"}}
  end

  def close_handle(_handle) do
    :ok
  end
end