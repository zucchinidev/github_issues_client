defmodule GithubIssuesClient.CLI do
  alias GithubIssuesClient.Http
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
      |> show_result
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

  def show_result(list) do
    header = get_header()
    rows = list |> Enum.map(&create_row_from_item/1)
    IO.puts [ header | rows ]
  end

  def create_row_from_item(item) do
    item |> get_fields |> padding |> create_row
  end

  def get_fields(item) do
    id = get_element(item, "id") |> to_string
    created_at = get_element(item, "created_at")
    title = get_element(item, "title")
    { id, created_at, title }
  end

  def get_element(map, element) do
    Map.get(map, element)
  end

  def padding({ id, created_at, title }, padding \\ " ") do
    id = padding_word(id, padding)
    created_at = padding_word(created_at, padding)
    title = padding_word(title, padding)
    { id, created_at, title}
  end

  def padding_word(word, padding) do
    String.pad_trailing(word, 50, padding)
  end

  def create_row({ id, created_at, title }, separator \\ "|") do
    pipe = " #{separator} "
    [ id, created_at, title]
            |> Enum.reduce([], fn element, acc -> [ pipe, element | acc ] end)
            |> Enum.into(["\n"])
            |> Enum.reverse
  end

  def get_separator do
    {"", "", ""}
      |> padding("-")
      |> create_row("+")
  end

  def get_header do
    header = {"ID", "Created at", "Title"}
      |> padding
      |> create_row
    [ header | get_separator() ]
  end
end