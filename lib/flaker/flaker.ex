defmodule Flaker do
  @moduledoc """
  Contains functions that are called when running `mix test.flaker`
  """
  @default_test_runs 5

  @doc """
  Delegated function called when `mix test.flake` is run
  """
  @spec run([String.t()]) :: no_return
  def run(args \\ []) do
    Mix.env(:test)
    run_tests(args)
  end

  defp run_tests(args) do
    {task, number_of_runs} = from_args(args)

    IO.puts("Running tests #{number_of_runs} times.....")

    1..number_of_runs
    |> Enum.map(fn _n -> shell_command(task) end)
    |> calculate_results(number_of_runs)
  end

  defp calculate_results(test_results, number_of_runs) do
    tally =
      Enum.reduce(test_results, %{failure: 0, success: 0}, fn x, acc ->
        Map.update(acc, x, 1, &(&1 + 1))
      end)

    IO.puts("#{number_of_runs} test runs performed")
    IO.puts("Results:")
    put_color_text(IO.ANSI.green(), "#{tally.success} successful run(s)")
    put_color_text(IO.ANSI.red(), "#{tally.failure} failed run(s)")
  end

  defp shell_command(task) do
    "mix"
    |> System.cmd(["test" | task], env: [{"MIX_ENV", "test"}])
    |> case do
      {_, 0} ->
        put_color_text(IO.ANSI.green(), ".")
        :success

      {_, 1} ->
        put_color_text(IO.ANSI.red(), ".")
        :failure
    end
  end

  def put_color_text(color, text) do
    IO.puts(color <> text <> IO.ANSI.reset())
  end

  defp from_args([]), do: {[], @default_test_runs}

  defp from_args(args) when is_list(args) do
    {last_item, remainder} = List.pop_at(args, -1)

    if Regex.match?(~r/^\d+$/, last_item) do
      extract_test_runs(last_item, remainder)
    else
      {rebuild_list(last_item, remainder), @default_test_runs}
    end
  end

  defp extract_test_runs(last_item, remainder) when is_list(remainder) do
    test_runs =
      last_item
      |> String.to_integer()
      |> abs()

    if test_runs > 99_999 or test_runs == 0 do
      {rebuild_list(last_item, remainder), @default_test_runs}
    else
      {remainder, test_runs}
    end
  end

  defp rebuild_list(last_item, remainder) do
    List.insert_at(remainder, -1, last_item)
  end
end
