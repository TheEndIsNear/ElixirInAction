defmodule ListHelper do
  def sum(list) do
    do_sum(0, list)
  end

  def list_len(list) do
    list_len(list, 0)
  end

  def range(from, to) when from < to do
    range(from, to, [])
  end 
  
  def range(from, to), do: Enum.reverse(range(to, from))

  def positive(list) do
    positive(list, [])
  end

  defp do_sum(current_sum, []) do
    current_sum
  end

  defp do_sum(current_sum, [head | tail]) do
    do_sum(current_sum + head, tail)
  end

  defp list_len([], count), do: count

  defp list_len([_head | tail], count) do
    list_len(tail, count+1)
  end


  defp range(to, to, list), do: list ++ [to]

  defp range(from, to, list) do
    range(from+1, to, list ++ [from]) 
  end

  defp positive([], list), do: list

  defp positive([head | tail], list) when head > 0 do
    positive(tail, list ++ [head])
  end

  defp positive([_head | tail], list) do
    positive(tail, list)
  end
end
