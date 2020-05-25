defmodule Todo.Server do
  use GenServer, restart: :temporary

  def start_link(name) do
    IO.puts("Starting to-do server for #{name}")
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def update_entry(pid, entry, update_func) do
    GenServer.cast(pid, {:update_entry, entry, update_func})
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  @impl true
  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  @impl true
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl true
  def handle_cast({:update_entry, entry, update_fun}, {name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry, update_fun)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl true
  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, new_list)
    {:noreply, Todo.List.delete_entry(todo_list, entry_id)}
  end

  @impl true
  def handle_call({:entries, date}, _, {name, todo_list}) do
    entries = Todo.List.entries(todo_list, date)
    {:reply, entries, {name, todo_list}}
  end

  defp via_tuple(name),  do: Todo.ProcessRegistry.via_tuple({__MODULE__, name})
end
