defmodule CarmineGql.StatsStorages.DCrdt do
  use Agent
  require Logger

  def start_link(_init_args) do
    Logger.debug("[Setup CRDT cache]")

    Agent.start_link(fn ->
      DeltaCrdt.start_link(DeltaCrdt.AWLWWMap, name: :crdt_cache)

      nodes = Node.list()

      if Enum.any?(nodes) do
        remote_crdt_caches = Enum.map(nodes, &{:crdt_cache, &1})
        local_crdt_cache = Process.whereis(:crdt_cache)
        DeltaCrdt.set_neighbours(:crdt_cache, remote_crdt_caches)
        Enum.each(remote_crdt_caches, &DeltaCrdt.set_neighbours(&1, [local_crdt_cache]))
      end
    end)
  end

  def get(key), do: DeltaCrdt.get(:crdt_cache, key)

  def hit(key) do
    current_value = get(key) || 0
    DeltaCrdt.put(:crdt_cache, key, current_value + 1)
  end
end
