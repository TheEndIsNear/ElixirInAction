defmodule Todo.Database do
  use GenServer

  alias Todo.DatabaseWorker

  @app_name __MODULE__
  @db_folder "./persist"

  def start_link do
    IO.puts("Starting database server.")
    GenServer.start_link(@app_name, %{})
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    id = :erlang.phash2(key, 3)
    GenServer.call(@app_name, {:get_worker, id})
  end

  @impl true
  def init(_) do
    send(self(), :start_workers)
    Process.register(self(), @app_name)
    {:ok, %{}}
  end

  @impl true
  def handle_call({:get_worker, id}, _, state) do
    worker_pid = Map.get(state, id)

    {:reply, worker_pid, state}
  end

  @impl true
  def handle_info(:start_workers, _state) do
    worker_map =
      for worker <- 0..2, into: %{} do
        {:ok, pid} = DatabaseWorker.start_link(@db_folder)
        {worker, pid}
      end

    {:noreply, worker_map}
  end
end
