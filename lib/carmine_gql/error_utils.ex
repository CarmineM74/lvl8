defmodule CarmineGql.ErrorUtils do
  def not_found(message \\ "not found", details \\ nil) do
    create_error(:not_found, message, details)
  end

  def internal_server_error(message \\ "internal server error", details \\ nil) do
    create_error(:internal_server_error, message, details)
  end

  def not_acceptable(message \\ "not acceptable", details \\ nil) do
    create_error(:not_acceptable, message, details)
  end

  def conflict(message \\ "conflict", details \\ nil) do
    create_error(:conflict, message, details)
  end

  defp create_error(code, message, nil), do: %{message: message, code: code}

  defp create_error(code, message, details) do
    %{message: message, code: code, details: details}
  end
end
