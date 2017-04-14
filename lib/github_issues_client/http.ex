defmodule GithubIssuesClient.Http do
  @github_url Application.get_env(:github_issues_client, :github_url)
  @user_agent [ {"User-agent", "zucchinidev"}]

  def fetch(user, project) do
    issues_url(user, project)
      |> HTTPoison.get(@user_agent)
      |> handle_response
  end

  defp issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  defp handle_response({ :ok, %{status_code: 200, body: body }}) do
      { :ok, parser(body) }
  end

  defp handle_response({ _ , %{status_code: _, body: body }}) do
        { :error, parser(body) }
  end

  defp parser(body), do: Poison.Parser.parse!(body)
end