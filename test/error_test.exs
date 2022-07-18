defmodule ErrorTest do
  use ExUnit.Case, async: true

  alias Error

  test "a domain error can be created with reason" do
    assert Error.domain(:reason) == %Error.DomainError{
             reason: :reason,
             details: %{},
             caused_by: :nothing
           }
  end

  test "a domain error can be created with reason and details" do
    assert Error.domain(:reason, %{extra: :info}) == %Error.DomainError{
             reason: :reason,
             details: %{extra: :info},
             caused_by: :nothing
           }
  end

  test "an infra error can be created with reason" do
    assert Error.infra(:db_down) == %Error.InfraError{
             reason: :db_down,
             details: %{},
             caused_by: :nothing
           }
  end

  test "an infra error can be created with reason and details" do
    assert Error.infra(:db_down, %{retried_count: 5}) == %Error.InfraError{
             reason: :db_down,
             details: %{retried_count: 5},
             caused_by: :nothing
           }
  end

  test "a domain error can be wrapped on top of an error" do
    inner = Error.infra(:inner)

    assert Error.wrap(inner, Error.domain(:outer)) ==
             %Error.DomainError{
               caused_by: {:just, inner},
               details: %{},
               reason: :outer
             }
  end

  test "an infra error can be wrapped on top of an error" do
    inner = Error.infra(:inner)

    assert Error.wrap(inner, Error.infra(:outer)) ==
             %Error.InfraError{
               caused_by: {:just, inner},
               details: %{},
               reason: :outer
             }
  end

  test "a domain error can be unwrapped from previously wrapped error" do
    inner = Error.domain(:inner)
    wrapped_domain_error = Error.wrap(inner, Error.domain(:outer))
    wrapped_infra_error = Error.wrap(inner, Error.domain(:outer))

    assert Error.unwrap(wrapped_domain_error) == inner
    assert Error.unwrap(wrapped_infra_error) == inner
  end

  test "an infra error can be unwrapped from previously wrapped error" do
    inner = Error.infra(:inner)
    wrapped_by_domain_error = Error.wrap(inner, Error.domain(:outer))
    wrapped_infra_error = Error.wrap(inner, Error.domain(:outer))

    assert Error.unwrap(wrapped_by_domain_error) == inner
    assert Error.unwrap(wrapped_infra_error) == inner
  end

  test "unwrapping error without a cause should return :nothing" do
    infra = Error.infra(:infra)
    domain = Error.domain(:domain)

    assert :nothing == Error.unwrap(infra)
    assert :nothing == Error.unwrap(domain)
  end

  test "error kind can be accessed" do
    error = Error.domain(:r, %{})
    assert Error.kind(error) == :domain
  end

  test "error reason can be accessed" do
    error = Error.domain(:a, %{c: :d})
    assert Error.reason(error) == :a
  end

  test "error cause can be accessed (domain cause)" do
    inner = Error.domain(:too_many_widgets)
    error = Error.wrap(inner, Error.domain(:user_limits_exceeded))
    assert Error.caused_by(error) == {:just, inner}
  end

  test "error cause can be accessed (infra cause)" do
    inner = Error.infra(:x_failure)
    error = Error.wrap(inner, Error.domain(:user_limits_exceeded))
    assert Error.caused_by(error) == {:just, inner}
  end

  test "error cause can be accessed from infra error" do
    inner = Error.infra(:x_failure)
    error = Error.wrap(inner, Error.infra(:general_failure))
    assert Error.caused_by(error) == {:just, inner}
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

    assert Error.to_map(error) == %{
             caused_by: :nothing,
             kind: :infra,
             reason: :x,
             details: %{y: :z, a: "b"}
           }
  end

  test "a wrapped error is recursively converted to a map" do
    inner = Error.infra(:i, %{inner_details: "abc"})

    outer =
      Error.wrap(
        inner,
        Error.domain(:o, %{outer_details: "xyz"})
      )

    assert Error.to_map(outer) == %{
             caused_by:
               {:just,
                %{caused_by: :nothing, kind: :infra, reason: :i, details: %{inner_details: "abc"}}},
             kind: :domain,
             reason: :o,
             details: %{outer_details: "xyz"}
           }
  end

  test "is_error is available as a guard for access in pattern matches" do
    import Error, only: [is_error: 1]

    m =
      case Error.infra(:my_reason, %{y: :z, a: "b"}) do
        f when is_integer(f) -> :no_reason
        e when is_error(e) -> Error.reason(e)
      end

    assert m == :my_reason
  end

  test "is_infra_error is available as a guard for access in pattern matches" do
    import Error, only: [is_infra_error: 1]

    m =
      case Error.domain(:my_reason, %{y: :z, a: "b"}) do
        e when is_infra_error(e) -> Error.reason(e)
        _other -> :not_matched
      end

    assert m == :not_matched
  end

  test "is_domain_error is available as a guard for access in pattern matches" do
    import Error, only: [is_domain_error: 1]

    m =
      case Error.infra(:my_reason, %{y: :z, a: "b"}) do
        e when is_domain_error(e) -> Error.reason(e)
        _other -> :not_matched
      end

    assert m == :not_matched
  end

  test "should flatten multiple nested errors" do
    root_cause = Error.domain(:root)
    layer_1 = Error.wrap(root_cause, Error.domain(:layer1))
    layer_2 = Error.wrap(layer_1, Error.infra(:layer2))
    layer_3 = Error.wrap(layer_2, Error.infra(:layer3))
    layer_4 = Error.wrap(layer_3, Error.domain(:layer4))

    assert [layer_4, layer_3, layer_2, layer_1, root_cause] == Error.flatten(layer_4)
  end

  test "flatten of non-nested error should just return it" do
    infra = Error.infra(:infra)
    domain = Error.domain(:domain)

    assert [infra] == Error.flatten(infra)
    assert [domain] == Error.flatten(domain)
  end

  test "should retrieve root cause of multiple nested errors" do
    root_cause = Error.domain(:root)
    layer_1 = Error.wrap(root_cause, Error.domain(:layer1))
    layer_2 = Error.wrap(layer_1, Error.infra(:layer2))
    layer_3 = Error.wrap(layer_2, Error.infra(:layer3))
    layer_4 = Error.wrap(layer_3, Error.domain(:layer4))

    assert root_cause == Error.root_cause(layer_4)
  end

  test "root cause of non-nested error is the error itself" do
    infra = Error.infra(:infra)
    domain = Error.domain(:domain)

    assert infra == Error.root_cause(infra)
    assert domain == Error.root_cause(domain)
  end
end
