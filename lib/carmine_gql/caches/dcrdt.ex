defmodule CarmineGql.Caches.DCrdt do
  require Logger

  def setup() do
    Logger.debug("[Setup CRDT cache]")
    nodes = Node.list()

    if Enum.any?(nodes) do
      remote_crdt_caches = Enum.map(nodes, &{:crdt_cache, &1})
      local_crdt_cache = Process.whereis(:crdt_cache)
      DeltaCrdt.set_neighbours(:crdt_cache, remote_crdt_caches)
      Enum.each(remote_crdt_caches, &DeltaCrdt.set_neighbours(&1, [local_crdt_cache]))
    end
    
  end

  def get(key), do: DeltaCrdt.get(:crdt_cache, key)

  def put(key, value), do: DeltaCrdt.put(:crdt_cache, key, value)
end
