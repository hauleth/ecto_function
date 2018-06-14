[
  inputs: [
    ".formatter.exs",
    "mix.exs",
    "lib/**.ex",
    "test/**.exs"
  ],
  import_deps: [:ecto],
  locals_without_parens: [defqueryfunc: 1, defqueryfunc: 2],
  export: [
    locals_without_parens: [defqueryfunc: 1, defqueryfunc: 2]
  ]
]
