defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(db_folder) do
    GenServer.start_link(
      __MODULE__,
      db_folder
    )
  end

  def store(worker_id, key, data) do
    GenServer.cast(worker_id, {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(worker_id, {:get, key})
  end

  @impl true
  def init(folder) do
    File.mkdir_p!(folder)
    {:ok, %{folder: folder}}
  end

  @impl true
  def handle_cast({:store, key, data}, %{folder: folder} = state) do
    folder
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl true
  def handle_call({:get, key}, _, %{folder: folder} = state) do
    data =
      case File.read(file_name(folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        {:error, :enoent} -> nil
      end

    {:reply, data, state}
  end

  defp file_name(folder, key) do
    Path.join(folder, to_string(key))
  end
end
