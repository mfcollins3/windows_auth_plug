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

defmodule Neudesic.WindowsAuthentication.Mixfile do
  use Mix.Project

  def project do
    [app: :neudesic_windows_auth_plug,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     compilers: [:elixir_make] ++ Mix.compilers]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:plug, "~> 1.3"},
      {:elixir_make, "~> 0.4.0", runtime: false}
    ]
  end

  defp description do
    """
    This library implements a custom plug that supports building Phoenix web
    applications that support integrated Windows authentication. This plug is
    intended for use in an Enterprise intranet environment where an Active
    Directory server is used for user authentication for a Windows domain.
    This plug allows a Phoenix web application to be hosted in IIS using the
    HttpPlatformHandler add-on. When Windows authentication is enabled,
    HttpPlatformHandler will add the X-IIS-WindowsAuthToken HTTP header to
    the request that is forwarded to the Phoenix web application. This plug
    will intercept that header and will add the Windows domain user name for
    the authenticated user to the Conn for the request.
    """
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["Michael Collins (michael.collins@neudesic.com)"],
      links: %{
        "GitHub" => "https://github.com/neudesic/windows_auth_plug"
      }
    ]
  end
end
