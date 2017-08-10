defmodule WebSpell.Request do
  @moduledoc "Represents a request consisting of the HTTP method and the URL (more to come). Pass Request structs to the functions in the WebSpell module."
  @enforce_keys [:method, :url]
  defstruct [:method, :url, :body]

  def match?(request_expectation, request_made) do
    request_expectation.url == request_made.url && request_expectation.method == request_made.method &&
      (request_expectation.body == nil || request_expectation.body == request_made.body)
  end
end

defimpl Inspect, for: WebSpell.Request do
  
  def inspect(request, _opts) do
    string = "<WebSpell.Request.#{String.upcase Atom.to_string(request.method)} #{request.url}>"
    if request.body do
      string <> " with body #{request.body}"
    else
      string
    end
  end
end