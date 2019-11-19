defmodule Error do
  @moduledoc """
  Model domain and infrastructure errors as regular data.
  """
  defstruct [:kind, :reason, :details]

  @type kind :: :domain | :infra
  @type reason :: atom()

  @opaque t(a) :: %__MODULE__{
            kind: kind,
            reason: reason,
            details: a
          }

  @opaque t :: t(map())

  @doc """
  Create a `domain` error, with a reason and optional details.
  """
  @spec domain(atom(), a) :: t(a) when a: map
  def domain(reason, details \\ %{}) when is_atom(reason) and is_map(details) do
    %__MODULE__{kind: :domain, reason: reason, details: details}
  end

  @doc """
  Create an `infra` error, with a reason and optional details.
  """
  @spec infra(atom(), a) :: t(a) when a: map
  def infra(reason, details \\ %{}) when is_atom(reason) and is_map(details) do
    %__MODULE__{kind: :infra, reason: reason, details: details}
  end

  @doc """
  Determine whether a given `Error` is a `domain` or `infra` error.
  """
  @spec kind(t) :: kind
  def kind(%__MODULE__{kind: kind}), do: kind

  @doc """
  Return the reason the `Error` was created with.
  """
  @spec reason(t) :: reason
  def reason(%__MODULE__{reason: reason}), do: reason

  @doc """
  Return the map of detailed information supplied at `Error` creation.
  """
  @spec details(t(a)) :: a when a: map
  def details(%__MODULE__{details: details}), do: details

  @doc """
  Map a function on the `details` map in an `Error`.

  Useful for adding extra details, modifying exisint ones, or removing them.
  """
  @spec map_details(t(a), (a -> b)) :: t(b) when a: map, b: map
  def map_details(%__MODULE__{details: details} = error, f) do
    %__MODULE__{error | details: f.(details)}
  end

  @doc """
  Convert an `Error` to an Elixir map.
  """
  @spec to_map(t) :: map
  def to_map(%__MODULE__{} = error), do: Map.from_struct(error)
end
