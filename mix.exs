defmodule EctoFunction.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_function,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),

      name: "Ecto.Function",

      package: package()
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ecto, ">= 2.0.0 and < 3.0.0", only: [:dev, :test]},
     {:postgrex, ">= 0.0.0", only: [:dev, :test]},
     {:ex_doc, "~> 0.14", only: :dev, runtime: false},
     {:ex_dash, ">= 0.0.0", only: :dev, runtime: false},
     {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
     {:credo, ">= 0.0.0", only: :dev, runtime: false}]
  end

  defp package do
    [maintainers: ["Łukasz Jan Niemier"],
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/hauleth/ecto_olap"
     }]
  end
end
