defmodule Ecto.Function do
  @moduledoc """
  Documentation for EctoFunction.
  """

  defmacro defqueryfunc({:/, _, {name, _, _}, args_count})
  when is_atom(name) and is_integer(args_count) do
    args = Macro.generate_arguments(args_count, Elixir)

    macro(name, args)
  end
  defmacro defqueryfunc({name, _, args})
  when is_atom(name) and is_list(args), do: macro(name, args)

  defp macro(name, args) do
    {query, args} = build_query(args)

    quote do
      defmacro unquote(name)(unquote_splicing(args)) do
        unquote(body(name, query, args))
      end
    end
  end

  defp body(name, query, args) do
    fcall = "#{name}(#{query})"
    args = Enum.map(args, &{:unquote, [], [&1]})

    {:quote, [], [[do: {:fragment, [], [fcall | args]}]]}
  end

  defp build_query(args, joiner \\ ",") do
    query =
      "?"
      |> List.duplicate(Enum.count(args))
      |> Enum.join(joiner)

    {query, args}
  end
end
