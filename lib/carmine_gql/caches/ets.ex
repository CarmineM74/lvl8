defmodule CarmineGql.Caches.Ets do
  def setup() do
    :ets.new(:ets_cache, [
      :named_table,
      :set,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])
  end

  def get(key) do
    case :ets.lookup(:ets_cache, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end

  def hit(key) do
    :ets.update_counter(:ets_cache, key, 1, {key, 0})
  end
end
