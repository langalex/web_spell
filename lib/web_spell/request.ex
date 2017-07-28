defmodule WebSpell.Request do
  @moduledoc "Represents a request consisting of the HTTP method and the URL (more to come). Pass Request structs to the functions in the WebSpell module."
  @enforce_keys [:method, :url]
  defstruct [:method, :url]
end

defimpl Inspect, for: WebSpell.Request do
  
  def inspect(request, _opts) do
    "<WebSpell.Request.#{String.upcase Atom.to_string(request.method)} #{request.url}>"
  end
end