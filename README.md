# Ecto.Function

[![Hex.pm](https://img.shields.io/hexpm/dt/ecto_function.svg)](https://hex.pm/packages/ecto_function)
[![Travis](https://img.shields.io/travis/hauleth/ecto_function.svg)](https://travis-ci.org/hauleth/ecto_function)

Helper macro for defining macros that simplifies calling DB functions.

## Installation

The package can be installed by adding `ecto_function` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_function, "~> 1.0.1"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/ecto_function>.

## Usage

When you use a lot of DB functions inside your queries then this probably looks
like this:

```elixir
from item in "items",
  where: fragment("date_trunc(?, ?)", "hour", item.inserted_at) < fragment("date_trunc(?, ?)", "hour", fragment("now()")),
  select: %{regr: fragment("regr_sxy(?, ?)", item.y, item.x)}
```

There are a lot of `fragment` calls which makes code quite challenging to read.
However there is way out for such code, you can write macros:

```elixir
defmodule Foo do
  defmacro date_trunc(part, field) do
    quote do: fragment("date_trunc(?, ?)", ^part, ^field)
  end

  defmacro now do
    quote do: fragment("now()")
  end

  defmacro regr_sxy(y, x) do
    quote do: fragment("regr_sxy(y, x)", ^y, ^x)
  end
end
```

And then cleanup your query to:

```elixir
import Foo
import Ecto.Query

from item in "items",
  where: date_trunc("hour", item.inserted_at) < date_trunc("hour", now()),
  select: %{regr: regr_sxy(item.y, item.x)}
```

However there is still a lot of repetition in your new fancy helper module. You
need to repeat function name twice, name each argument, insert all that carets
and stuff.

What about little help?

```elixir
defmodule Foo do
  import Ecto.Function

  defqueryfunc date_trunc(part, field)
  defqueryfunc now
  defqueryfunc regr_sxy/2
end
```

Much cleaner…

## Reasoning

[Your DB is powerful](http://modern-sql.com/slides). Really. A lot of
computations can be done there. There is whole [chapter][chapter] dedicated to
describing all PostgreSQL functions and Ecto supports only few of them:

- `sum`
- `avg`
- `min`
- `max`

To be exact. Saying that we have "limited choice" would be disrespectful to DB
systems like PostgreSQL or Oracle. Of course Ecto core team have walid reasoning
to support only that much functions: these are available in probably any DB
system ever, so supporting them directly in library is no brainer. However you
as end-user shouldn't be limited to so small set. Let's be honest, you probably
will never change your DB engine, and if you do so, then you probably rewrite
while system from the ground. So this is why this module was created. To provide
you access to all functions in your SQL DB (could work with NoSQL DB also, but I
test only against PostgreSQL).

For completeness you can also check [Ecto.OLAP][olap] which provide helpers for
some more complex functionalities like `GROUPING` (and in near future also
window functions).

### But why not introduce that directly to Ecto?

Because there is no need. Personally I would like to see Ecto splitted a little,
like changesets should be in separate library in my humble opinion. Also I
believe that such PR would never be merged as "non scope" for the reasons I gave
earlier.

[chapter]: https://www.postgresql.org/docs/current/static/functions.html "Chapter 9. Functions and Operators"
[olap]: https://github.com/hauleth/ecto_olap
