defmodule Functions do
  import Ecto.Function

  defqueryfunc cbrt(dp)
end

defmodule Ecto.FunctionTest do
  use ExUnit.Case

  doctest Ecto.Function

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

    test "do not compiles when params aren't correct" do
      code = """
      import Ecto.Function

      defmodule Test3 do
        defqueryfunc test(a, foo(funky))
      end
      """

      assert_raise CompileError, fn ->
        Code.compile_string(code)
      end
    end
  end

  describe "example function (cbrt)" do
    import Ecto.Query
    import Functions

    alias Ecto.Integration.Repo

    setup do
      Repo.insert_all("example", Enum.map(1..10, &%{value: &1}))

      :ok
    end

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
end
