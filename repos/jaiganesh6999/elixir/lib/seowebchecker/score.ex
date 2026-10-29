defmodule SeoWebChecker.Score do
  @moduledoc """
  Calculated numerical SEO score (0-100) and letter grade (A-F).
  """

  @type t :: %__MODULE__{
          overall: non_neg_integer(),
          grade: String.t()
        }

  @enforce_keys [:overall, :grade]
  defstruct [:overall, :grade]
end
