defmodule GithubIssuesClient.TableFormatter do
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