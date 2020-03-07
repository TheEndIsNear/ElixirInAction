defmodule TodoServer do
  use GenServer
  
  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end


  def add_entry(new_entry) do
    GenServer.cast(__MODULE__, {:add_entry, new_entry})
  end

  def update_entry(entry, update_func) do
    GenServer.cast(__MODULE__, {:update_entry, entry, update_func})
  end

  def delete_entry(entry_id) do
    GenServer.cast(__MODULE__, {:delete_entry, entry_id})
  end
  
  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end

  @impl true
  def init(_) do
    {:ok, TodoList.new()}
  end

  @impl true
  def handle_cast({:add_entry, new_entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, new_entry)}
  end

  @impl true
  def handle_cast({:update_entry, entry, update_fun}, todo_list) do
    {:noreply, TodoList.update_entry(todo_list, entry, update_fun)}
  end

  @impl true
  def handle_cast({:delete_entry, entry_id}, todo_list) do
    {:noreply, TodoList.delete_entry(todo_list, entry_id)}
  end

  @impl true
  def handle_call({:entries, date},_ , todo_list) do
    {:reply, TodoList.entries(todo_list, date), todo_list}
  end
end

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
  def add_entry(%TodoList{} = todo_list, entry) do
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
  def entries(%TodoList{} = todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  @doc """
  Update an entry based upon an entry id, and a function for updating the entry
  """
  def update_entry(%TodoList{}= todo_list, entry_id, updater_fun) do
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

  def update_entry(%TodoList{} = todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end
  
  @doc """
  Deletes an entry from the todo list, based on the id given
  """
  def delete_entry(%TodoList{} = todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id), auto_id: todo_list.auto_id - 1}
  end

  defimpl String.Chars, for: TodoList do
    def to_string(_) do
      "#TodoList"
    end
  end

  defimpl Collectable, for: TodoList do
    def into(original) do
      {original, &into_callback/2}
    end

    defp into_callback(todo_list, {:cont, entry}) do
      TodoList.add_entry(todo_list, entry)
    end
    defp into_callback(todo_list, :done), do: todo_list
    defp into_callback(_todo_list, :halt), do: :ok
  end
end
