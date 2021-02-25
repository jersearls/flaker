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
    |> Enum.map(fn run_number -> shell_command(task, run_number) end)
    |> calculate_results(number_of_runs)
  end

  defp calculate_results(test_results, number_of_runs) do
    final_tally =
      test_results
      |> tally_results()
      |> reduce_test_failures()

    IO.puts("\n#{number_of_runs} test runs performed.\n")
    IO.puts("Results:")
    put_color_text(:green, "#{final_tally.success_number} successful run(s)")
    put_color_text(:red, "#{final_tally.failure_number} failed run(s)")
  end

  defp tally_results(test_results) do
    acc = %{failure_number: 0, success_number: 0, failing_tests: []}

    Enum.reduce(test_results, acc, fn
      {:success, _}, acc ->
        Map.update!(acc, :success_number, &(&1 + 1))

      {:failure, failure_string}, acc ->
        acc
        |> Map.update!(:failure_number, &(&1 + 1))
        |> Map.update!(:failing_tests, fn existing_list -> [failure_string | existing_list] end)
    end)
  end

  defp reduce_test_failures(tallied_results) do
    {failing_tests, _new_tallied_results} = Map.pop!(tallied_results, :failing_tests)

    # Gonna need a custom formatter to easily parse the output without tons
    # of regex
    failing_tests
    |> IO.inspect()

    # |> Enum.map()

    tallied_results
  end

  defp shell_command(task, run_number) do
    "mix"
    |> System.cmd(["test" | task], env: [{"MIX_ENV", "test"}])
    |> case do
      {_, 0} ->
        put_color_text(:green, "#{run_number}")
        {:success, nil}

      {failure_text, 1} ->
        put_color_text(:red, "#{run_number}")
        # TODO write a parser to split up failure text into a map
        # with list of strings for each failed test
        # %{test_output: ["test 1", "test 2"], seed:""}
        {:failure, failure_text}
    end
  end

  def put_color_text(color, text) do
    IO.puts(apply(IO.ANSI, color, []) <> text <> IO.ANSI.reset())
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
