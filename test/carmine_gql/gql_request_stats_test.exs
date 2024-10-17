defmodule CarmineGql.GqlRequestStatsTest do
  use ExUnit.Case, async: true

  alias CarmineGql.GqlRequestStats

  setup do
    {:ok, _pid} = CarmineGql.GqlRequestStats.start_link(name: nil)
    :ok
  end

  describe "&get_hit_counter/2" do
    test "Querying a nil key won't crash the process" do
      pid1 = Process.whereis(GqlRequestStats)
      assert(pid1)
      GqlRequestStats.get_hit_counter(nil)
      pid2 = Process.whereis(GqlRequestStats)
      assert pid2 === pid1
    end

    test "Querying an empty key always returns 0" do
      assert 0 === GqlRequestStats.get_hit_counter("")
      GqlRequestStats.hit("")
      assert 0 === GqlRequestStats.get_hit_counter("")
    end

    test "Returns 0 if given request has never been hit" do
      assert 0 === GqlRequestStats.get_hit_counter("a request")
    end

    test "Returns the number of hits for the given request" do
      GqlRequestStats.hit("a request")
      refute 0 === GqlRequestStats.get_hit_counter("a request")
    end
  end

  describe "&hit/2" do
    test "Hitting a nil key will won't crash the process" do
      pid1 = Process.whereis(GqlRequestStats)
      assert(pid1)
      GqlRequestStats.hit(nil)
      pid2 = Process.whereis(GqlRequestStats)
      assert pid2 === pid1
    end

    test "Each hit increments counter by one for the given request" do
      assert 0 === GqlRequestStats.get_hit_counter("a request")
      GqlRequestStats.hit("a request")
      hit_counter = GqlRequestStats.get_hit_counter("a request")
      assert hit_counter === 1
    end

    test "Hitting a request doesn't affect other counters" do
      GqlRequestStats.hit("a request")
      GqlRequestStats.hit("a request")
      GqlRequestStats.hit("other request")
      assert 1 === GqlRequestStats.get_hit_counter("other request")
      assert 2 === GqlRequestStats.get_hit_counter("a request")
    end
  end
end
