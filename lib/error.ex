defmodule Error do
  @moduledoc """
  Model domain and infrastructure errors as regular data.
  """

  alias FE.Maybe

  defmodule DomainError do
    @moduledoc false
    defstruct [:reason, :details, caused_by: :nothing]
  end

  defmodule InfraError do
    @moduledoc false
    defstruct [:reason, :details, caused_by: :nothing]
  end

  @type kind :: :domain | :infra
  @type reason :: atom()
  @opaque t(a) :: %DomainError{reason: reason, details: a}
                | %InfraError{reason: reason, details: a}

  @opaque t :: t(map())

  @doc """
  Create a `domain` error, with a reason and optional details.
  """
  @spec domain(atom(), a) :: t(a) when a: map
  def domain(reason, details \\ %{}) when is_atom(reason) and is_map(details) do
    %DomainError{reason: reason, details: details}
  end

  @doc """
  Create an `infra` error, with a reason and optional details.
  """
  @spec infra(atom(), a) :: t(a) when a: map
  def infra(reason, details \\ %{}) when is_atom(reason) and is_map(details) do
    %InfraError{reason: reason, details: details}
  end

  @doc """
  Determine whether a given `Error` is a `domain` or `infra` error.
  """
  @spec kind(t) :: kind
  def kind(%DomainError{}), do: :domain
  def kind(%InfraError{}), do: :infra

  @doc """
  Return the reason the `Error` was created with.
  """
  @spec reason(t) :: reason
  def reason(%DomainError{reason: reason}), do: reason
  def reason(%InfraError{reason: reason}), do: reason

  @doc """
  Return the map of detailed information supplied at `Error` creation.
  """
  @spec details(t(a)) :: a when a: map
  def details(%DomainError{details: details}), do: details
  def details(%InfraError{details: details}), do: details

  @doc """
  Map a function on the `details` map in an `Error`.

  Useful for adding extra details, modifying exisint ones, or removing them.
  """
  @spec map_details(t(a), (a -> b)) :: t(b) when a: map, b: map
  def map_details(%DomainError{details: details} = error, f) do
    %DomainError{error | details: f.(details)}
  end
  def map_details(%InfraError{details: details} = error, f) do
    %InfraError{error | details: f.(details)}
  end

  @doc """
  Wrap a higher-level error 'on top' of a lower-level error.

  Think of this as a stack trace, but in domain-model terms.
  """
  @spec wrap(t(a), t(a)) :: t(a) when a: map
  def wrap(inner, %DomainError{} = outer) do
    %{outer | caused_by: Maybe.just(inner)}
  end
  def wrap(inner, %InfraError{} = outer) do
    %{outer | caused_by: Maybe.just(inner)}
  end

  @doc """
  Extract the cause of an error (of type `Error.t()`).

  Think of this as inspecting deeper into the stack trace.
  """
  @spec caused_by(t(a)) :: Maybe.t(t(a)) when a: map
  def caused_by(%DomainError{caused_by: c}), do: c
  def caused_by(%InfraError{caused_by: c}), do: c

  @doc """
  Convert an `Error` to an Elixir map.
  """
  @spec to_map(t) :: map
  def to_map(%DomainError{} = e), do: Map.from_struct(e) |> Map.put(:kind, :domain)
  def to_map(%InfraError{} = e), do: Map.from_struct(e)|> Map.put(:kind, :infra)
end
