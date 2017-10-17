defmodule Ecto.Function do
  @moduledoc """
  Documentation for EctoFunction.
  """

  defmacro defqueryfunc({name, _, args}, opts \\ [])
  when is_atom(name) and is_list(args) do
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
