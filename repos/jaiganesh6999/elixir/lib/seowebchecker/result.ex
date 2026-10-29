defmodule SeoWebChecker.Result do
  @moduledoc """
  Complete technical SEO audit report.
  """

  alias SeoWebChecker.{Issue, Score}

  @type t :: %__MODULE__{
          url: String.t(),
          score: Score.t(),
          total_checks: non_neg_integer(),
          passed_checks: non_neg_integer(),
          warnings: non_neg_integer(),
          errors: non_neg_integer(),
          issues: list(Issue.t()),
          metadata: map()
        }

  @enforce_keys [:url, :score, :total_checks, :passed_checks, :warnings, :errors, :issues, :metadata]
  defstruct [:url, :score, :total_checks, :passed_checks, :warnings, :errors, :issues, :metadata]
end
