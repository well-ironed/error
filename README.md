# Error [![CircleCI](https://circleci.com/gh/well-ironed/error.svg?style=svg)](https://circleci.com/gh/well-ironed/error)

Errors modeled as data.

## Installation


```elixir
def deps do
  [
    {:error, "~> 0.1.0"}
  ]
end
```

## Creation

Errors come in two kinds:

1. `:domain` errors, which are part of your business model, or *Domain* in DDD
   parlance. You can use the map in the second argument position to supply
   whatever extra details you find useful:

```
    Error.domain(:invalid_username, %{
     provided_username: "alex",
     unmet_requirement: "Must start with capital letter"}
    })
```

2. `:infra` errors, which represent failures of the infrastructure or
   computation substrate. Similarly, you can supply a map as the second
   argument, with arbitrary details of your choosing.

```
    Error.infra(:db_down, %{retried_count: 5})
```

## Usage

Errors should be created at the place where they occur. Domain errors can be
later converted to user-facing messages, in the presentation logic.

Infra errors, on the other hand, most often translate to a "500 error" and the
only piece of information that an end-user needs to know is that "Something
went wrong".  At the same time, you want to log these errors extensively so
that you can investigate the issue later.

Errors provide a convenient `to_map` function, so that your view logic doesn't
need to know about the `Error` type.
