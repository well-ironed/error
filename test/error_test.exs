defmodule ErrorTest do
  use ExUnit.Case, async: true

  alias Error

  test "a domain error can be created with reason" do
    assert Error.domain(:reason) == %Error.DomainError{
             reason: :reason,
             details: %{}
           }
  end

  test "a domain error can be created with reason and details" do
    assert Error.domain(:reason, %{extra: :info}) == %Error.DomainError{
             reason: :reason,
             details: %{extra: :info}
           }
  end

  test "an infra error can be created with reason" do
    assert Error.infra(:db_down) == %Error.InfraError{
             reason: :db_down,
             details: %{}
           }
  end

  test "an infra error can be created with reason and details" do
    assert Error.infra(:db_down, %{retried_count: 5}) == %Error.InfraError{
             reason: :db_down,
             details: %{retried_count: 5}
           }
  end

  test "error kind can be accessed" do
    error = Error.domain(:r, %{})
    assert Error.kind(error) == :domain
  end

  test "error reason can be accessed" do
    error = Error.domain(:a, %{c: :d})
    assert Error.reason(error) == :a
  end

  test "error details can be accessed when set explicitly" do
    error = Error.domain(:i, %{k: :l})
    assert Error.details(error) == %{k: :l}
  end

  test "default error details can be accessed" do
    error = Error.domain(:m)
    assert Error.details(error) == %{}
  end

  test "details can be mapped over" do
    error = Error.domain(:m, %{a: :b, c: :d})
    error = Error.map_details(error, fn d -> Map.put(d, :e, :f) end)
    assert Error.details(error) == %{a: :b, c: :d, e: :f}
  end

  test "it can be converted to map" do
    error = Error.infra(:x, %{y: :z, a: "b"})
    assert Error.to_map(error) == %{kind: :infra, reason: :x, details: %{y: :z, a: "b"}}
  end
end
