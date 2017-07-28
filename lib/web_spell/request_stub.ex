defmodule WebSpell.RequestStub do
  @enforce_keys [:request, :response]
  defstruct [:request, :response]
end