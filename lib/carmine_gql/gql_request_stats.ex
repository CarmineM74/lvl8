defmodule CarmineGql.GqlRequestStats do
  use GenServer

  require Logger
  alias __MODULE__

  @moduledoc """
  Chosen strategy:
    - DeltaCRDT

  Why?
    - We are fine with eventual consistency 
      - we fall in the dashboard data case  
    - We want to have high Availability and Network partition tolerance
      - survivor nodes will serve the data in the event of a network split 
    - Our cluster is small
    - The amount of data to replicate across the cluster is small
  """

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name) || GqlRequestStats
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @impl true
  def init(init_state) do
    {:ok, init_state, {:continue, :setup_crdt_cache}}
  end

  @impl true
  def handle_continue(:setup_crdt_cache, state) do
    Logger.debug("[Setup CRDT cache]")
    nodes = Node.list()
    remote_crdt_caches = Enum.map(nodes, &{:crdt_cache, &1})
    local_crdt_cache = Process.whereis(:crdt_cache)
    DeltaCrdt.set_neighbours(:crdt_cache, remote_crdt_caches)
    Enum.each(remote_crdt_caches, &DeltaCrdt.set_neighbours(&1, [local_crdt_cache]))

    {:noreply, state}
  end

  def get_hit_counter(nil), do: 0

  def get_hit_counter(request) when is_binary(request) do
    case DeltaCrdt.get(:crdt_cache, request) do
      nil -> 0
      counter -> counter
    end
  end

  def hit(""), do: :ok
  def hit(nil), do: :ok

  def hit(request)
      when is_binary(request) do
    current_value = get_hit_counter(request)
    DeltaCrdt.put(:crdt_cache, request, current_value + 1)
    :ok
  end
end
