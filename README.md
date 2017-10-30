# Ecto.Function

Helper macro for defining macros that simplifies calling DB functions.

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

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_function` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_function, "~> 1.0.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ecto_function](https://hexdocs.pm/ecto_function).

[chapter]: https://www.postgresql.org/docs/current/static/functions.html "Chapter 9. Functions and Operators"
[olap]: https://github.com/hauleth/ecto_olap
