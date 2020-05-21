defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(folder) do
    IO.puts("Starting database worker.")
    GenServer.start_link(__MODULE__, folder)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
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
        _ -> nil
      end

    {:reply, data, state}
  end

  defp file_name(folder, key) do
    Path.join(folder, to_string(key))
  end
end
