defmodule CarmineGql.Caches.DCrdt do
  require Logger

  def setup() do
    Logger.debug("[Setup CRDT cache]")

    {:ok, pid} = DeltaCrdt.start_link(DeltaCrdt.AWLWWMap, name: :crdt_cache)

    nodes = Node.list()

    if Enum.any?(nodes) do
      remote_crdt_caches = Enum.map(nodes, &{:crdt_cache, &1})
      local_crdt_cache = Process.whereis(:crdt_cache)
      DeltaCrdt.set_neighbours(:crdt_cache, remote_crdt_caches)
      Enum.each(remote_crdt_caches, &DeltaCrdt.set_neighbours(&1, [local_crdt_cache]))
    end

    {:ok, pid}
  end

  def get(key), do: DeltaCrdt.get(:crdt_cache, key)

  def hit(key) do
    current_value = get(key) || 0
    DeltaCrdt.put(:crdt_cache, key, current_value + 1)
  end
end
