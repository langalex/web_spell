defmodule WebSpell.Response do
  @enforce_keys [:body]
  defstruct body: nil, status: 200
end