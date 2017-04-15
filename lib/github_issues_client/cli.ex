defmodule GithubIssuesClient.CLI do
  alias GithubIssuesClient.Http
  alias GithubIssuesClient.TableFormatter
  @default_count 4
  @moduledoc """
  Handle the command line parsing and the dispatch to the various functions
  that end up generating a table of the last _n_ issues in a github project
  """

  def run(argv) do
    argv
      |> parse_args
      |> process
  end

  @doc """
  `argv` can be -h or --help, witch returns :help.
  Otherwise it is a github user name, project name, and (optionally) the number of entries to format.

  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                      aliases:  [h: :help])
    case parse do
      { [ help: true ], _, _ } -> :help
      { _, [ user, project, count ], _} -> { user, project, String.to_integer(count) }
      { _, [ user, project ], _} -> { user, project, @default_count }
      _ -> :help
    end

  end
  
  def process(:help) do
    IO.puts """
    Usage: github_issues_client <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({ user, project, count }) do
    Http.fetch(user, project)
      |> decode_response
      |> sort_into_ascending_order
      |> Enum.take(count)
      |> TableFormatter.show_result
  end

  def decode_response({ :ok, body}), do: body
  def decode_response({ :error, error}) do
    message = Map.get(error, "message")
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end
  
  def sort_into_ascending_order(list_of_issues) do
    Enum.sort list_of_issues,
      fn issue_one, issue_two ->
        Map.get(issue_one, "created_at") <= Map.get(issue_two, "created_at")
      end
  end
end