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
    ErrorUtils.conflict("conflict on insert or update", traverse_errors(changeset))
  end

  defp handle_error(error), do: [error]

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
