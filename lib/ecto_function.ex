defmodule Ecto.Function do
  @moduledoc """
  Documentation for EctoFunction.
  """

  defmacro defqueryfunc({:/, _, [{name, _, _}, params_count]})
  when is_atom(name) and is_integer(params_count) do
    params = Macro.generate_arguments(params_count, Elixir)

    macro(name, params, __CALLER__)
  end
  defmacro defqueryfunc({name, _, params})
  when is_atom(name) and is_list(params) do
    macro(name, params, __CALLER__)
  end

  defp macro(name, params, caller) do
    {query, args} = build_query(params, caller)

    quote do
      defmacro unquote(name)(unquote_splicing(params)) do
        unquote(body(name, query, args))
      end
    end
  end

  defp body(name, query, args) do
    fcall = "#{name}(#{query})"
    args = Enum.map(args, &{:unquote, [], [&1]})

    {:quote, [], [[do: {:fragment, [], [fcall | args]}]]}
  end

  defp build_query(args, joiner \\ ",", caller) do
    query =
      "?"
      |> List.duplicate(Enum.count(args))
      |> Enum.join(joiner)
    args =
      args
      |> Enum.map(fn
        {:\\, _, [{_, _, _} = arg, _default]} -> arg
        {_, _, env} = arg when is_atom(env) -> arg
        token ->
          raise CompileError,
            file: caller.file,
            line: caller.line,
            description: "Expected argument got #{Macro.to_string token}"
      end)

    {query, args}
  end
end
