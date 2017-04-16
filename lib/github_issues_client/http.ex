defmodule GithubIssuesClient.Http do
  require Logger

  @github_url Application.get_env(:github_issues_client, :github_url)
  @user_agent [ {"User-agent", "zucchinidev"}]

  def fetch(user, project) do
    Logger.info "Fetching user #{user}'s project #{project}"
    issues_url(user, project)
      |> HTTPoison.get(@user_agent)
      |> handle_response
  end

  defp issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  defp handle_response({ :ok, %{status_code: 200, body: body }}) do
    Logger.info "Successfull response"
    Logger.debug fn -> inspect(body) end
    { :ok, parser(body) }
  end

  defp handle_response({ _ , %{status_code: status, body: body }}) do
    Logger.error "Error status: #{status} returned"
    { :error, parser(body) }
  end

  defp parser(body), do: Poison.Parser.parse!(body)
end