defmodule CarmineGql.StatsStorages.Singleton do
  use GenServer
  require Logger

  def start_link(_init_args) do
    case(GenServer.start_link(__MODULE__, [], name: via_tuple(:singleton_storage))) do
      {:ok, pid} ->
        Logger.debug("[StatsStorages.Singleton] Starting ...")
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.debug("[StatsStorages.Singleton] Already started on #{inspect(pid)}.")
        :ignore
    end
  end

  def get(key), do: GenServer.call(via_tuple(:singleton_storage), {:get, key})
  def hit(key), do: GenServer.cast(via_tuple(:singleton_storage), {:hit, key})

  @impl true
  def init(_args) do
    Logger.debug("[StatsStorages.Singleton.init]")

    :ets.new(:ets_cache, [
      :named_table,
      :set,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])

    {:ok, nil}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    res =
      case :ets.lookup(:ets_cache, key) do
        [{^key, value}] -> value
        [] -> nil
      end

    {:reply, res, state}
  end

  @impl true
  def handle_cast({:hit, key}, state) do
    :ets.update_counter(:ets_cache, key, 1, {key, 0})
    {:noreply, state}
  end

  defp via_tuple(name), do: {:via, Horde.Registry, {CarmineGql.HRegistry, name}}
end
