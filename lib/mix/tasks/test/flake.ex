defmodule Mix.Tasks.Test.Flake do
  use Mix.Task

  @moduledoc """
  A task for running tests multiple times to determine if they are flaky.
  """
  @shortdoc "Automatically run tests multiple times to ascertain their flakiness"
  @preferred_cli_env :test

  defdelegate run(args), to: Flaker
end
