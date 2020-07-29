defmodule SimpleRegisty do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(name) do
    case :ets.insert_new(__MODULE__, {name, self()}) do
      true ->
        :ok

      false ->
        :error
    end
  end

  def whereis(name) do
    :ets.lookup(__MODULE__, name)
  end

  @impl true
  def init(_) do
    :ets.new(
      __MODULE__,
      [:named_table, :public, write_concurrency: true]
    )

    {:ok, nil}
  end

  @impl true
  def handle_info({:EXIT, pid, _reason}, state) do
    :ets.match_delete(__MODULE__, {:_, pid})
    {:noreply, state}
  end
end
