defmodule CarmineGqlWeb.Schema.Middlewares.ChangesetErrors do
  @behaviour Absinthe.Middleware
  require Logger
  alias CarmineGql.ErrorUtils

  def call(resolution, _opts) do
    mapped_changeset_errors = Enum.map(resolution.errors, &handle_error/1)
    %{resolution | errors: mapped_changeset_errors}
  end

  defp handle_error(%Ecto.Changeset{action: action} = changeset)
       when action in [:insert, :update] do
    error_details = traverse_errors(changeset)

    if Map.has_key?(error_details, :email) do
      ErrorUtils.conflict("email conflict on #{action}", error_details)
    else
      ErrorUtils.bad_request("bad request", error_details)
    end
  end

  defp handle_error(error), do: error

  defp traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts
        |> Keyword.get(String.to_existing_atom(key), key)
        |> to_string()
      end)
    end)
  end
end
