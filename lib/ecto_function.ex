defmodule Ecto.Function do
  @moduledoc """
  Helper macro for defining helper macros for calling DB functions.

  A little Xzibity, but helps.
  """

  @doc ~S"""
  Define new SQL function call.

  ## Options

  Currently there is only one option allowed:

  - `for` - define DB function name to call

  ## Examples

      import Ecto.Function

      defq foo                    # Define function without params
      defq bar(a, b)              # Explicit parameter names
      defq baz(a, b \\ 0)         # Define function with default arguments
      defq qux(a), for: "db_qux"  # Define with alternative DB call

  Then calling such functions in query would be equivalent to:

      from _ in "foos", select: %{foo: foo()}
      # => SELECT foo() AS foo FROM foos

      from q in "bars", select: %{bar: bar(q.a, q.b)}
      # => SELECT bar(bars.a, bars.b) AS bar FROM bars

      from q in "bazs", select: %{one: baz(q.a), two: baz(q.a, q.b)}
      # => SELECT
      #      baz(bazs.a, 0) AS one,
      #      baz(bazs.a, bazs.b) AS two
      #    FROM "bazs"

      from q in "quxs", select: %{qux: qux(q.a)}
      # => SELECT db_qux(quxs.a) FROM quxs

  ## Gotchas

  If your function uses "special syntax" like PostgreSQL [`extract`][extract]
  then this module won't help you and you will be required to write your own
  macro that will handle such case.

      defmacro extract(from, field) do
        query do: fragment("extract(? FROM ?)", field, from)
      end

  This case probably will never be supported in this library and you should
  handle it on your own.

  [extract]: https://www.postgresql.org/docs/current/static/functions-datetime.html#functions-datetime-extract
  """
  defmacro defq(definition, opts \\ []), do: build(:defmacro, __CALLER__, definition, opts)

  defmacro defqp(definition, opts \\ []), do: build(:defmacrop, __CALLER__, definition, opts)

  defp build(macro, caller, {name, _, params}, opts)
       when is_atom(name) and is_list(params) do
    opts = Keyword.put_new(opts, :for, name)

    macro(macro, name, params, caller, opts)
  end

  defp build(macro, caller, {name, _, _}, opts) when is_atom(name) do
    opts = Keyword.put_new(opts, :for, name)

    macro(macro, name, [], caller, opts)
  end

  defp build(_, caller, tree, _) do
    raise CompileError,
      file: caller.file,
      line: caller.line,
      description: "Unexpected query function definition #{Macro.to_string(tree)}."
  end

  defp macro(macro, name, params, caller, opts) do
    body =
      case Keyword.fetch(opts, :do) do
        {:ok, ast} ->
          EctoFunction.BodyBuilder.build(ast, params)

        _ ->
          sql_name = Keyword.fetch!(opts, :for)
          {query, args} = build_query(params, caller)

          fcall = "#{sql_name}(#{query})"

          quote bind_quoted: [args: [fcall | args]] do
            quote do: fragment(unquote_splicing(args))
          end
      end

    quote do
      unquote(macro)(unquote(name)(unquote_splicing(params)), do: unquote(body))
    end
  end

  defp build_query(args, caller) do
    query =
      "?"
      |> List.duplicate(Enum.count(args))
      |> Enum.join(",")

    args =
      args
      |> Enum.map(fn
        {:\\, _, [{_, _, _} = arg, _default]} ->
          arg

        {_, _, env} = arg when is_atom(env) ->
          arg

        _token ->
          raise CompileError,
            file: caller.file,
            line: caller.line,
            description: ~S"only variables and \\ are allowed as arguments in definition header."
      end)

    {query, args}
  end
end
