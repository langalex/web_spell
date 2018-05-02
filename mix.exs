defmodule WebSpell.Mixfile do
  use Mix.Project

  def project do
    [
      app: :web_spell,
      version: "0.4.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "WebSpell",
      source_url: "https://github.com/langalex/web_spell"
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: []]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp description do
    """
      WebSpell is an HTTP mocking library for Elixir. It is somewhat inspired by WebMock for Ruby, but adapted to the different programming environment of Elixir.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :web_spell,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Alexander Lang"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/langalex/web_spell"}
    ]
  end
end
