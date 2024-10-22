defmodule CarmineGql.Test.Support do
  use ExUnit.Case

  alias CarmineGqlWeb.Schema

  def test_failure_with_error(doc_test, opts \\ []) do
    variables = Keyword.get(opts, :variables, %{})
    context = Keyword.get(opts, :context, %{})
    error_message = Keyword.get(opts, :error_message)
    error_code = Keyword.get(opts, :error_code)

    assert {:ok, %{errors: errors}} =
             Absinthe.run(doc_test, Schema, context: context, variables: variables)

    assert errors
    [error] = errors

    error
    |> maybe_check_error_message(error_message)
    |> maybe_check_error_code(error_code)
  end

  defp maybe_check_error_message(error, nil), do: error

  defp maybe_check_error_message(error, error_message) do
    assert error.message === error_message
    error
  end

  defp maybe_check_error_code(error, nil), do: error

  defp maybe_check_error_code(error, error_code) do
    assert error.code === error_code
    error
  end
end
