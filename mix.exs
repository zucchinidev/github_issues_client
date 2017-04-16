defmodule GithubIssuesClient.Mixfile do
  use Mix.Project

  def project do
    [app: :github_issues_client,
     version: "0.1.0",
     elixir: "~> 1.4",
     escript: escript_config,
     name: "Github issues client",
     source_url: "https://github.com/zucchinidev/github_issues_client",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :httpoison]]
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
    [
      {:httpoison, "~> 0.11.1"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.15.0"},
      {:earmark, "~> 1.2", override: true}
    ]
  end

  defp escript_config do
    [ main_module: GithubIssuesClient.CLI]
  end
end
