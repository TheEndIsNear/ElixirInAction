defmodule Todo.Database do
  use GenServer

  alias Todo.DatabaseWorker

  @app_name __MODULE__
  @db_folder "./persist"

  def start do
    GenServer.start(@app_name, %{})
  end

  def store(key, data) do
    worker_pid = choose_worker(key)
    GenServer.cast(worker_pid, {:store, key, data})
  end

  def get(key) do
    worker_pid = choose_worker(key)
    GenServer.call(worker_pid, {:get, key})
  end

  def choose_worker(key) do
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
  def handle_cast({:store, key, data}, state) do
    key
    |> file_name()
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl true
  def handle_call({:get, key}, _, state) do
    data =
      case File.read(file_name(key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, state}
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
        {:ok, pid} = DatabaseWorker.start(@db_folder)
        {worker, pid}
      end

    {:noreply, worker_map}
  end

  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
