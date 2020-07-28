defmodule SimpleRegisty do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(name) do
    GenServer.call(__MODULE__, {:register, name, self()})
  end

  def whereis(name) do
    GenServer.call(__MODULE__, {:whereis, name})
  end

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  @impl true
  def handle_call({:register, name, pid}, _, state) do
    case Map.get(state, name) do
      nil ->
        new_state = Map.put(state, name, pid)
        {:reply, :ok, new_state}

      _pid ->
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:whereis, name}, _, state) do
    pid = Map.get(state, name)
    {:reply, pid, state}
  end

  @impl true
  def handle_info({:EXIT, pid, _reason}, state) do
    new_state =
      state
      |> Enum.filter(fn %{key: value} -> value == pid end)
      |> Enum.map(&Map.delete(state, &1))

    {:noreply, new_state}
  end
end
