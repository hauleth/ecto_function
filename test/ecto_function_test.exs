defmodule Functions do
  import Ecto.Function

  defqueryfunc cbrt(dp)

  defqueryfunc sqrt/1

  defqueryfunc regr_syy(y, x \\ 0)
end

defmodule Ecto.FunctionTest do
  use ExUnit.Case

  alias Ecto.Integration.Repo

  doctest Ecto.Function

  setup_all do
    Repo.insert_all("example", Enum.map(1..10, &%{value: &1}))

    on_exit fn ->
      Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    end

    :ok
  end

  describe "compilation" do
    test "with defined macro compiles" do
      code = """
      import Ecto.Function

      defmodule Test1 do
      defqueryfunc test(a, b)
      end
      """

      assert match?([{Test1, _}], Code.compile_string(code))
    end

    test "with defined macro using slashed syntax compiles" do
      code = """
      import Ecto.Function

      defmodule Test2 do
      defqueryfunc test/2
      end
      """

      assert match?([{Test2, _}], Code.compile_string(code))
    end

    test "with default params" do
      code = """
      import Ecto.Function

      defmodule Test4 do
      defqueryfunc test(a, b \\\\ 1)
      end
      """

      assert match?([{Test4, _}], Code.compile_string(code))
    end

    test "do not compiles when params aren't correct" do
      code = """
      import Ecto.Function

      defmodule Test3 do
      defqueryfunc test(a, foo(funky))
      end
      """

      assert_raise CompileError,
        "nofile:4: Expected argument got foo(funky)",
        fn ->
          Code.compile_string(code)
        end
    end
  end

  describe "example function defined by params list" do
    import Ecto.Query
    import Functions

    test "return correct computation" do
      result = Repo.all from item in "example", select: cbrt(item.value)

      assert result == [
        1.0,
        1.2599210498948732,
        1.4422495703074083,
        1.5874010519681996,
        1.709975946676697,
        1.8171205928321397,
        1.9129311827723892,
        2.0,
        2.080083823051904,
        2.154434690031884]
    end
  end

  describe "example function defined by params count" do
    import Ecto.Query
    import Functions

    test "return correct computation" do
      result = Repo.all from item in "example", select: sqrt(item.value)

      assert Enum.map(result, &Decimal.to_float/1) == [
        1.000000000000000,
        1.414213562373095,
        1.732050807568877,
        2.000000000000000,
        2.236067977499790,
        2.449489742783178,
        2.645751311064591,
        2.828427124746190,
        3.000000000000000,
        3.162277660168379]
    end
  end

  describe "example function defined by params list with defaults" do
    import Ecto.Query
    import Functions

    test "when called with both arguments" do
      result = Repo.all from item in "example", select: regr_syy(item.value, 0)

      assert result == [82.5]
    end

    test "when called with one argument" do
      result = Repo.all from item in "example", select: regr_syy(item.value)

      assert result == [82.5]
    end
  end
end
