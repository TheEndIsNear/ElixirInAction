defmodule TodoCacheTest do
  use ExUnit.Case
  alias Todo.Cache

  test "server_process" do
    Cache.start_link()
    bob_pid = Cache.server_process("bob")

    assert bob_pid != Cache.server_process("alice")
    assert bob_pid == Cache.server_process("bob")
  end

  test "to-do operations" do
    Cache.start_link()
    alice = Todo.Cache.server_process("alice")
    Todo.Server.add_entry(alice, %{date: ~D[2018-12-19], title: "Dentist"})
    entries = Todo.Server.entries(alice, ~D[2018-12-19])

    assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
  end
end
