defmodule SeoWebChecker.Issue do
  @moduledoc """
  Represents an individual diagnostic check finding.
  """

  @type severity :: :pass | :warning | :error

  @type t :: %__MODULE__{
          id: String.t(),
          category: String.t(),
          severity: severity(),
          title: String.t(),
          message: String.t(),
          recommendation: String.t()
        }

  @enforce_keys [:id, :category, :severity, :title, :message, :recommendation]
  defstruct [:id, :category, :severity, :title, :message, :recommendation]
end
