defmodule ListHelper do
  def sum(list) do
    do_sum(0, list)
  end

  def list_len([]), do: 0

  def list_len([_head|tail]) do
    1 + list_len(tail)
  end

  defp do_sum(current_sum, []) do
    current_sum
  end

  defp do_sum(current_sum, [head | tail]) do
    do_sum(current_sum + head, tail)
  end
end
