defmodule CarmineGql.GqlRequestStats do
  use Agent

  alias __MODULE__

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name) || GqlRequestStats
    state = Keyword.get(opts, :state, %{})
    Agent.start_link(fn -> state end, name: name)
  end

  def get_hit_counter(request, agent \\ __MODULE__)
  def get_hit_counter(nil, _agent), do: 0

  def get_hit_counter(request, agent)
      when is_binary(request) and (is_pid(agent) or is_atom(agent)) do
    Agent.get(agent, fn state ->
      Map.get(state, request, 0)
    end)
  end

  def hit(request, agent \\ __MODULE__)
  def hit("", _agent), do: :ok
  def hit(nil, _agent), do: :ok

  def hit(request, agent)
      when is_binary(request) and (is_pid(agent) or is_atom(agent)) do
    Agent.update(agent, fn state ->
      Map.update(state, request, 1, &(&1 + 1))
    end)
  end
end
