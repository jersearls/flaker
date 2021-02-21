defmodule Mix.Tasks.Test.Flake do
  use Mix.Task

  @moduledoc """
  A task for running tests multiple times to determine if they are flaky.

  `mix test.flake` will respect any arguments that would be normally given
  to `mix test`, with the addition that, optionally, an integer may be passed
  as the final argument to indicate the number of test repititions. If no integer
  is passed, `mix.test.flake` will use a default value.

  Example:

  `mix test.flake test/flaker_test.exs:6 --seed 677193 50`

  The command above will run the test at line 6 of the file found at
  the path `test/flaker_test.exs`, using seed 677193 50 times.
  """
  @shortdoc "Automatically run tests multiple times to ascertain their flakiness"
  @preferred_cli_env :test

  defdelegate run(args), to: Flaker
end
