defmodule CliTest do
  use ExUnit.Case
  doctest GithubIssuesClient

  import GithubIssuesClient.CLI, only: [
                                          parse_args: 1,
                                          sort_into_ascending_order: 1,
                                          decode_response: 1
                                       ]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end
  
  test "three values returned if three given" do
    assert parse_args(["user", "project", "99"]) == { "user", "project", 99 }
  end

  test "count is defaulted if two values givent" do
    assert parse_args(["user", "project"]) == { "user", "project", 4 }
  end
  
  test "sort ascending order the correct way" do
    dates = [
      "2016-01-08",
      "2016-10-12",
      "2016-06-27",
      "2016-03-20"
    ]
    result = sort_into_ascending_order(fake_created_at_list(dates))
    issues = for issue <- result do
      Map.get(issue, "created_at")
    end

    assert issues == ~w(2016-01-08 2016-03-20 2016-06-27 2016-10-12)
  end

  test "decode response from fetch request" do
    body = "ok!!"
    result = decode_response({ :ok, body })
    assert result == body
  end



  defp fake_created_at_list(list) do
    for item <- list do
      %{"created_at" => item, "other_data": "xxx"}
    end
  end
end