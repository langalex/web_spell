defmodule WebSpell.RequestStub do
  @moduledoc "Represents a request stub, consisting of a Request and a Response."

  @enforce_keys [:request, :response]
  defstruct [:request, :response]
end