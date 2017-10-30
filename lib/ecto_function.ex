defmodule Ecto.Function do
  @moduledoc """
  Helper macro for defining helper macros for calling DB functions.

  A little Xzibity, but helps.
  """

  @doc """
  Define new SQL function call.

  ## Options

  Currently there is only one option allowed:

  - `for` - define DB function name to call

  ## Examples

      import Ecto.Function

      defqueryfunc foo                    # Define function without params
      defqueryfunc bar(a, b)              # Explicit parameter names
      defqueryfunc baz/1                  # Define function using arity
      defqueryfunc qux(a, b \\ 0)         # Define function with default arguments
      defqueryfunc quux/1, for: "db_quux" # Define with alternative DB call

  Then calling such functions in query would be equivalent to:

      from _ in "foos", select: %{foo: foo()}
      # => SELECT foo() AS foo FROM foos

      from q in "bars", select: %{bar: bar(q.a, q.b)}
      # => SELECT bar(bars.a, bars.b) AS bar FROM bars

      from q in "bazs", where: baz(q.a) == true
      # => SELECT * FROM bazs WHERE baz(bazs.a) = TRUE

      from q in "quxs", select: %{one: qux(q.a), two: qux(q.a, q.b)}
      # => SELECT
      #      qux(quxs.a, 0) AS one,
      #      qux(quxs.a, quxs.b) AS two
      #    FROM "quxs"

      from q in "quuxs", select: %{quux: quux(q.a)}
      # => SELECT db_quux(quuxs.a) FROM quuxs

  ## Gotchas

  If your function uses "special syntax" like PostgreSQL [`extract`][extract]
  then this module won't help you and you will be required to write your own
  macro that will handle such case.

      defmacro extract(from, field) do
        query do: fragment("extract(? FROM ?)", field, from)
      end

  This case probably will never be supported in this library and you should
  handle it on your own.
  """
  defmacro defqueryfunc(definition, opts \\ [])
  defmacro defqueryfunc({:/, _, [{name, _, _}, params_count]}, opts)
  when is_atom(name) and is_integer(params_count) do
    opts = Keyword.put_new(opts, :for, name)
    params = Macro.generate_arguments(params_count, Elixir)

    macro(name, params, __CALLER__, opts)
  end
  defmacro defqueryfunc({name, _, params}, opts)
  when is_atom(name) and is_list(params) do
    opts = Keyword.put_new(opts, :for, name)

    macro(name, params, __CALLER__, opts)
  end
  defmacro defqueryfunc(name, opts) when is_atom(name) do
    opts = Keyword.put_new(opts, :for, name)

    macro(name, [], __CALLER__, opts)
  end
  defmacro defqueryfunc(tree, _) do
    raise CompileError,
      file: __CALLER__.file,
      line: __CALLER__.line,
      description: "Unexpected query function definition #{Macro.to_string tree}."
  end

  defp macro(name, params, caller, opts) do
    sql_name = Keyword.fetch!(opts, :for)
    {query, args} = build_query(params, caller)

    quote do
      defmacro unquote(name)(unquote_splicing(params)) do
        unquote(body(sql_name, query, args))
      end
    end
  end

  defp body(name, query, args) do
    fcall = "#{name}(#{query})"
    args = Enum.map(args, &{:unquote, [], [&1]})

    {:quote, [], [[do: {:fragment, [], [fcall | args]}]]}
  end

  defp build_query(args, caller) do
    query =
      "?"
      |> List.duplicate(Enum.count(args))
      |> Enum.join(",")
    args =
      args
      |> Enum.map(fn
        {:\\, _, [{_, _, _} = arg, _default]} -> arg
        {_, _, env} = arg when is_atom(env) -> arg
        _token ->
          raise CompileError,
            file: caller.file,
            line: caller.line,
            description: "only variables and \\\\ are allowed as arguments in definition header."
      end)

    {query, args}
  end
end
