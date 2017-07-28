# WebSpell

[![Build Status](https://travis-ci.org/langalex/web_spell.svg?branch=master)](https://travis-ci.org/langalex/web_spell)

WebSpell is an HTTP mocking library for Elixir. It is somewhat inspired by WebMock for Ruby, but adapted to the different programming environment of Elixir.

## Motivation

When I started my first Elixir/Phoenix web app and started looking for ways to stub calls to external services, all I found was a few blog posts that told me to replace my HTTP client with a (static) module for testing like this:

    defmodule TestStub do
      def get("http://example.com/1") do
        {:ok, "resource 1"}
      end

      def get("http://example.com/2") do
        {:ok, "resource 2"}
      end
      # etc.
    end

This way my tests wouldn't hit any real endpoints and stay fast. This approach may work for projects communicating very little with the outside world, but not for what I'm doing. What you are doing essentially is creating fixtures, i.e. some static data that all your tests depend on. As your test suite grows, you need more of them, and whenever you change one, something breaks somewhere else.

So what I needed was a way to set up stubbed web requests that were different for every test case. Say hello to WebSpell.

## Installation

The package can be installed by adding `web_spell` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:web_spell, "~> 0.1.0"}]
end
```

## Usage

Please note: the examples below use the Poison library for JSON parsing/encoding.

You start with a module that calls your HTTP client of choice:

    defmodule MyWebClient do
      def get_user
        HTTPoison.get("http://example.com/user", {access_token: "123"}, {Accept: "application/json"})
      end
    end

To start using WebSpell, make the HTTP client configurable by using a module attribute. 

    # a module that uses any HTTP client to make request
    defmodule MyWebClient do
      @http_client Application.get_env(:my_app, :http_client) # either an actual HTTP client module or your mock module

      def get_user
        {:ok, response} = @http_client.get("http://example.com/user", {access_token: "123"}, {Accept: "application/json"})

        Poison.Parser.parse!(response.body)
      end
    end

For development/production environments, configure your normal client:

    # config/config.exs
    use Mix.Config
    import_config "#{Mix.env}.exs"

    # config/prod.exs / config/dev.exs
    use Mix.Config
    config :my_app, http_client: HTTPoison

    # config/test.exs
    use Mix.Config
    config :my_app, http_client: MockHTTPClient

And implement a mock HTTP client using WebSpell:

    defmodule MockHTTPClient do
      use WebSpell

      def get(url, query, headers) do
        response = call_stubbed_request! %Request{method: :get, url: url, query: query, headers: headers}
        {:ok, response.body} # emulate the behavior of your production HTTP client
      end
    end

Finally you can start writing tests using WebSpell:

    defmodule MyWebClientTest do
      use ExUnit.Case, async: false # sorry, WebSpell can only handle one test at a time

      setup do
        MockHTTPClient.start_link()
        :ok
      end

      test "get_user returns user data" do
        MockHTTPClient.stub_request(
          %WebSpell.Request{
            method: :get,
            url: "http://example.com/user",
            query: {access_token: "123"}, # optional
            headers: {Accept: "application/json"} # optional
          },
          %WebSpell.Response{
            status_code: 200,
            body: Poison.encode!(%{"email" => "user@example.com"}) # convert to JSON
          }
        )

        user = MyWebClient.get_user

        assert user == {"email" => "user@example.com"}
        assert MockHTTPClient.received_request(%{method: :get, url: "http://example.com/user",
                                                 query: {access_token: "123"}, 
                                                 headers: {Accept: "application/json"}})
        assert MockHTTPClient.received_no_request(%{method: :get, url: "http://example.com/account"})
      end
    end

## TODO

* implement query params, headers

## Ideas

Add support for a few popular HTTP clients and return responses matching them instead of just WebSpell.Response.