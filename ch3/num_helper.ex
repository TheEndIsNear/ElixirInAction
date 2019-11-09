defmodule NumHelper do
  def sum_nums(enumerable) do
    Enum.reduce(enumerable, 0, &add_num/2)
  end

  defp add_num(num, sum) when is_number(num), do: sum + num
  defp add_num(_, sum), do: sum
end
