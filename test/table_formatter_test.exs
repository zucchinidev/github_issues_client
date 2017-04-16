defmodule TableFormatterTest do
  use ExUnit.Case
  doctest GithubIssuesClient
  import GithubIssuesClient.TableFormatter, only: [
                                           padding: 2,
                                           padding_word: 2,
                                           get_fields: 1,
                                           create_row: 2,
                                           get_separator: 0,
                                           get_header: 0,
                                           show_result: 1
                                         ]
  import ExUnit.CaptureIO

  test "padding word with a character" do
    left = pad("foo")
    result = padding_word("foo", "*")
    assert left == result
  end
  
  test "padding a tuple with spaces" do
    id_pad = pad("id")
    title_pad = pad("title")
    created_at_pad = pad("created_at")
    assert padding({"id", "title", "created_at"}, "*") == { id_pad, title_pad, created_at_pad }
  end

  test "get fields for map of results" do
    first = List.first(get_mock_data())
    assert get_first_item() == get_fields(first)
  end

  test "create_row for map of results" do
    { id, created_at, title } = get_first_item()
    separator = " | "
    row = [id, separator, created_at, separator, title, separator, "\n"]
    assert row == create_row(get_first_item(), "|")
  end

  test "one line split result" do
    assert get_mock_separator() == get_separator()
  end

  test "header of table" do
    header = [get_mock_header() | get_mock_separator()]
    assert header == get_header()
  end

  test "correct format returned" do
    result = capture_io(fn ->
      show_result(get_mock_data())
    end)
    assert result == """
    #{simple_test_data()}
    """
  end

  defp pad(word) do
    String.pad_trailing(word, 50, "*")
  end

  defp get_first_item do
    first = List.first(get_mock_data())
    id = Map.get(first, "id")
    title = Map.get(first, "title")
    created_at = Map.get(first, "created_at")
    { to_string(id), created_at, title }
  end

  defp get_mock_data do
    [
      %{
         "created_at" => "2016-01-08T19:34:22Z",
         "id" => 125677936,
         "title" => "Update Phoenix website"
       },
      %{
        "created_at" => "2016-03-20T14:57:25Z",
        "id" => 142171742,
        "title" => "Asset paths are wrong when forwarding in router"
      }
    ]
  end

  defp get_mock_separator do
    line = "--------------------------------------------------"
    plus = " + "
    [line, plus, line, plus, line, plus, "\n"]
  end

  defp get_mock_header do
    {"ID", "Created at", "Title"} |> padding(" ") |> create_row("|")
  end
  
  defp simple_test_data do
    pad = fn (word) ->
      String.pad_trailing(word, 50, " ")
    end
    separator = " | "
    get_mock_header() ++ get_mock_separator() ++
    [
      pad.("125677936"), separator,
      pad.("2016-01-08T19:34:22Z"), separator,
      pad.("Update Phoenix website"), separator, "\n",
      pad.("142171742"), separator,
      pad.("2016-03-20T14:57:25Z"), separator,
      pad.("Asset paths are wrong when forwarding in router"), separator, "\n"
    ]
  end
end