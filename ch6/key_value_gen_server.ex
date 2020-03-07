defmodule KeyValueStore do
  use GenServer

  def start do
    :timer.send_interval(5000, :cleanup)
    GenServer.start(KeyValueStore, nil)
  end

  def put(pid, key, value) do
    GenServer.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
     {:noreply, Map.put(state, key, value)}
  end

  @impl true
  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    IO.puts("performing cleanup...")
    {:noreply, state}
  end
end
