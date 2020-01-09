defmodule EctoFunction.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_function,
      version: "1.0.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Ecto.Function",
      description: """
      Simple macro for defining macro that will return `fragment` with SQL function.

      A little bit Xzibit, but fun.
      """,
      package: package(),
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0", only: [:dev, :test]},
      {:ecto_sql, ">= 0.0.0", only: [:dev, :test]},
      {:postgrex, ">= 0.0.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Łukasz Jan Niemier"],
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/hauleth/ecto_function"
      }
    ]
  end
end
