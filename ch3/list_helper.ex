defmodule ListHelper do
  def sum(list) do
    do_sum(0, list)
  end

  def list_len([]), do: 0
  def list_len([_head|tail]) do
    1 + list_len(tail)
  end

  def range(from, to) when from < to do
    range(from, to, [])
  end 
  
  def range(from, to), do: Enum.reverse(range(to, from))

  defp do_sum(current_sum, []) do
    current_sum
  end

  defp do_sum(current_sum, [head | tail]) do
    do_sum(current_sum + head, tail)
  end

  defp range(to, to, list), do: list ++ [to]
  defp range(from, to, list) do
    range(from+1, to, list ++ [from]) 
  end
end
