defmodule WebSpell.Request do
  @enforce_keys [:method, :url]
  defstruct [:method, :url]
end

defimpl Inspect, for: WebSpell.Request do
  
  def inspect(request, _opts) do
    "<WebSpell.Request.#{String.upcase Atom.to_string(request.method)} #{request.url}>"
  end
end