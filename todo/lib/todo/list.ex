defmodule Todo.List do
  @moduledoc """
  """
  defstruct auto_id: 1, entries: %{}

  @doc """
  Creates a new Todo.List
  """
  def new(), do: %Todo.List{}

  @doc """
  Add a new entry to a todo list
  """
  def add_entry(%Todo.List{} = todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.auto_id,
        entry
      )

    %Todo.List{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  @doc """
  List all entries for a given date
  """
  def entries(%Todo.List{} = todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  @doc """
  Update an entry based upon an entry id, and a function for updating the entry
  """
  def update_entry(%Todo.List{}= todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def update_entry(%Todo.List{} = todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end
  
  @doc """
  Deletes an entry from the todo list, based on the id given
  """
  def delete_entry(%Todo.List{} = todo_list, entry_id) do
    %Todo.List{todo_list | entries: Map.delete(todo_list.entries, entry_id), auto_id: todo_list.auto_id - 1}
  end

  defimpl String.Chars, for: Todo.List do
    def to_string(_) do
      "#Todo.List"
    end
  end

  defimpl Collectable, for: Todo.List do
    def into(original) do
      {original, &into_callback/2}
    end

    defp into_callback(todo_list, {:cont, entry}) do
      Todo.List.add_entry(todo_list, entry)
    end
    defp into_callback(todo_list, :done), do: todo_list
    defp into_callback(_todo_list, :halt), do: :ok
  end
end

