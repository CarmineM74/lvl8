defmodule CarmineGql.RedisCache do
  @pool_size 10
  @max_overflow 10
  @pool_name :redis_pool

  def child_spec(opts) do
    :poolboy.child_spec(@pool_name, [
      name: {:local, @pool_name},
      worker_module: Redix,
      size: opts[:pool_size] || @pool_size,
      max_overflow: opts[:max_overflow] || @max_overflow
    ], [host: "localhost", port: 6379])
  end

  def get(key) do
    :poolboy.transaction(@pool_name, fn pid ->
      with {:ok, value} <- Redix.command(pid, ["GET", key]) do
        if is_binary(value) do
          {:ok, :erlang.binary_to_term(value)}
        else
          {:ok, value}
        end
      end
    end) 
  end

  def put(key, ttl \\ nil, value)
  
  def put(key, nil, value) do
    :poolboy.transaction(@pool_name, fn pid ->
      with {:ok, "OK"} <- Redix.command(pid, ["SET", key, :erlang.term_to_binary(value)]) do
        :ok
      end
    end) 
  end

  def put(key, ttl, value) do
    ttl_sec = ceil(ttl / 1000)
    :poolboy.transaction(@pool_name, fn pid ->
      with {:ok, "OK"} <- Redix.command(pid, ["SETEX", key, ttl_sec, :erlang.term_to_binary(value) ]) do
        :ok
      end
    end)
    
  end
  
end
