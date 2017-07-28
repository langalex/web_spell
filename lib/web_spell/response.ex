defmodule WebSpell.Response do
  @moduledoc "Represents a response to a stubbed request, consisting of the HTTP status and the body. Pass Response structs to the functions in the WebSpell module."
  @enforce_keys [:body]
  defstruct body: nil, status: 200
end