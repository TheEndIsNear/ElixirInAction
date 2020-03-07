defmodule Todo.Server do
  def start do
    pid = spawn(fn -> loop(Todo.List.new()) end)
    Process.register(pid, :todo_server)
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  def update_entry(entry, update_func) do
    send(:todo_server, {:update_entry, entry, update_func})
  end

  def delete_entry(entry_id) do
    send(:todo_server, {:delete_entry, entry_id})
  end
  
  def entries(date) do
    send(:todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message ->
           process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    Todo.List.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:update_entry, entry, update_fun}) do
    Todo.List.update_entry(todo_list, entry, update_fun)
  end

  defp process_message(todo_list, {:delete_entry, entry_id}) do
    Todo.List.delete_entry(todo_list, entry_id)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, Todo.List.entries(todo_list, date)})
    todo_list
  end
end
