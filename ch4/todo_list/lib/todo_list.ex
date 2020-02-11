defmodule TodoList do
  @moduledoc """
  """
  defstruct auto_id: 1, entries: %{}

  @doc """
  Creates a new TodoList
  """
  def new(), do: %TodoList{}

  @doc """
  Add a new entry to a todo list
  """
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.auto_id,
        entry
      )

    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  @doc """
  List all entries for a given date
  """
  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  @doc """
  Update an entry based upon an entry id, and a function for updating the entry
  """
  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end
  
  @doc """
  Deletes an entry from the todo list, based on the id given
  """
  def delete_entry(todo_list, entry_id) do
    Map.delete(todo_list, entry_id) 
  end
end

defmodule TodoList.CsvImporter do

  def import(filename) do
    File.stream!(filename)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&parse_date/1)
    |> Stream.map(&create_map/1)
    |> Enum.reduce(%TodoList{}, &TodoList.add_entry(&2, &1))
  end

  defp parse_date([date|tail]) do
    [year, month, day] =
    date
    |> String.split("/") 
    |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)
    [ date | tail]
  end

  defp create_map([date | [task]]) do
    %{date: date, title: task}
  end
end
