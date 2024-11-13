defmodule CarmineGql.GqlRequestStats do
  use GenServer

  alias __MODULE__

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name) || GqlRequestStats

    request_counters =
      :ets.new(:request_counters, [
        :named_table,
        :set,
        :public,
        read_concurrency: true,
        write_concurrency: true
      ])

    GenServer.start_link(__MODULE__, request_counters, name: name)
  end

  @impl true
  def init(init_state) do
    {:ok, init_state}
  end

  def get_hit_counter(nil), do: 0

  def get_hit_counter(request) when is_binary(request) do
    case :ets.lookup(:request_counters, request) do
      [{^request, counter}] -> counter
      [] -> 0
    end
  end

  def hit(""), do: :ok
  def hit(nil), do: :ok

  def hit(request)
      when is_binary(request) do
    :ets.update_counter(:request_counters, request, 1, {request, 0})
  end
end
