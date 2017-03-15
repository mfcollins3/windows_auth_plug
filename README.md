# Windows Authentication Plug

## Introduction

This library implements a plug that works with IIS and
[HttpPlatformHandler](https://www.iis.net/downloads/microsoft/httpplatformhandler)
to implement support for integrated Windows authentication for Phoenix
web applications. HttpPlatformHandler adds a request handler to IIS
that will execute a child process and forward requests from IIS to the
child process. In the case of a Phoenix web application,
HttpPlatformHandler can be configured to run the Phoenix web server to
handle requests that are sent to IIS. IIS in this case becomes a proxy.
The Phoenix application is able to take advantage of services that are
supported by IIS, including integrated Windows authentication. This
module will allow developers to build enterprise intranet web
applications using Elixir and Phoenix.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `neudesic_windows_auth_plug` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:neudesic_windows_auth_plug, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/neudesic_windows_auth_plug](https://hexdocs.pm/neudesic_windows_auth_plug).

## Deployment

To deploy a Phoenix web application to a Windows server running IIS and
HttpPlatformModule, create a `web.config` file in the root directory of
your project:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <system.webServer>
        <handlers>
            <add name="httpplatformhandler" path="*" verb="*" modules="httpPlatformHandler" resourceType="Unspecified"/>
        </handlers>
        <httpPlatform processPath="mix"
            arguments="phoenix.server"
            stdoutLogEnabled="true"
            forwardWindowsAuthToken="true">
            <environmentVariables>
                <environmentVariable name="MIX_ENV" value="prod"/>
            </environmentVariables>
        </httpPlatform>
    </system.webServer>
</configuration>
```

The `forwardWindowsAuthToken` argument will cause HttpPlatformHandler
to add the `X-IIS-WindowsAuthToken` header to HTTP requests that are
forwarded to the Phoenix wen application. `X-IIS-WindowsAuthToken`
contains the handle for the authenticated user's token. The plug can
use this handle to retrieve the user's information. The user's domain
name and user name will be added to the `Conn.assigns` map using the
`:windows_user` key.

After creating the `web.config` file, you can create a new application
or website in IIS and point the website or application to the root
directory where the `web.config` file is located.
