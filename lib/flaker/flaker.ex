defmodule Flaker do
  @moduledoc """
  Contains functions that are called when running `mix test.flaker`
  """

  use Application

  @default_test_runs 20
  @ansi "run -e 'Application.put_env(:elixir, :ansi_enabled, true);'"

  @doc """
  Delegated function called when `mix test.flake` is run
  """
  @spec run([String.t()]) :: no_return
  def run(args \\ []) do
    Mix.env(:test)
    IO.puts("Running tests.....")
    IO.puts(shell_command(args))
    # # :ok = Application.ensure_started(:mix_test_watch)
    # Watcher.run_tasks()
  end

  defp shell_command(args) do
    command = build_task_command(args)

    command
    # Path.join(:code.priv_dir(:mix_test_watch), "zombie_killer")
    # |> System.cmd(["sh", "-c", command], into: IO.stream(:stdio, :line))
    # System.cmd(["sh", "-c", command])
  end

  defp build_task_command(args) do
    {task, _number_of_runs} = from_args(args)

    "MIX_ENV=test mix do #{@ansi}, #{task}"
  end

  defp from_args([]), do: {"", @default_test_runs}

  defp from_args(args) when is_list(args) do
    {last_item, remainder} = List.pop_at(args, -1)

    if Regex.match?(~r/^\d+$/, last_item) do
      extract_test_runs(last_item, remainder)
    else
      {rebuild_list_as_string(last_item, remainder), @default_test_runs}
    end
  end

  defp extract_test_runs(last_item, remainder) when is_list(remainder) do
    test_runs =
      last_item
      |> String.to_integer()
      |> abs()

    if test_runs > 99_999 or test_runs == 0 do
      {rebuild_list_as_string(last_item, remainder), @default_test_runs}
    else
      {Enum.join(remainder, " "), test_runs}
    end
  end

  defp rebuild_list_as_string(last_item, remainder) do
    remainder
    |> List.insert_at(-1, last_item)
    |> Enum.join(" ")
  end

  # def start(_type, _args) do
  #   import Supervisor.Spec, warn: false

  #   children = [
  #     worker(Watcher, [])
  #   ]

  #   opts = [strategy: :one_for_one, name: Sup.Supervisor]
  #   Supervisor.start_link(children, opts)
  # end
end
