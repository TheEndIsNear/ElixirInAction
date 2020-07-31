if Node.connect(:todo_system@localhost) == true do
  :rpc.call(:todo_system@localhost, System, :stop, [])
  IO.puts("Node termintated")
else
  IO.puts("Can't connect to the remote node.")
end
