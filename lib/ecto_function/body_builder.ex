defmodule EctoFunction.BodyBuilder do
  def build(ast, params) do
    params = Enum.map(params, &extract_arg/1)
    {fragment, args} = build_fragment(ast, params)

    quote bind_quoted: [args: [fragment | args]] do
      quote do: fragment(unquote_splicing(args))
    end
  end

  defp build_fragment({:cond, _env, [[do: cases]]}, params) do
    {fragment, args} = condition_fragment(cases, params, [], [])

    {"CASE #{fragment} END", args}
  end

  defp condition_fragment([], _, fragment, args),
    do: {Enum.reverse(fragment), Enum.reverse(args)}

  defp condition_fragment([{:->, _, [[true], result]}], params, fragment, args) do
  result = unquote_params(result, params)
    condition_fragment([], params, [" ELSE ?" | fragment], [Macro.escape(result, unquote: true) | args])
  end

  defp condition_fragment([{:->, _env, [[condition], result]} | rest], params, fragment, args) do
  condition = unquote_params(condition, params)
  result = unquote_params(result, params)
    condition_fragment(rest, params, [" WHEN ? THEN ?" | fragment], [Macro.escape(result, unquote: true), Macro.escape(condition, unquote: true)] ++ args)
  end

  defp unquote_params(ast, params) do
    Macro.postwalk(ast, fn
      {name, _, atom} = entry when is_atom(atom) ->
      if name in params do
        {:unquote, [], [entry]}
      else
        entry
      end
    other -> other
    end)
  end

  defp extract_arg({:\\, _, [{name, _, _}, _]}), do: name
  defp extract_arg({name, _, _}), do: name
end
