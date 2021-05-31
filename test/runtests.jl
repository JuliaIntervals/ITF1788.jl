using ITF1788
using Test

@testset "parse line" begin

    # simple 1 output commands
    @test parse_command("add [10.0, 20.0] [13.0, 17.0] = [23.0, 37.0];") == "@test +(interval(10.0, 20.0), interval(13.0, 17.0)) == Interval(23.0, 37.0)"
    @test parse_command("add [10.0, 20.0] [13.0, 17.0] = [23.0, 38.0];") == "@test_skip +(interval(10.0, 20.0), interval(13.0, 17.0)) == Interval(23.0, 38.0)"
    @test parse_command("add [10.0, 20.0] [13.0, 17.0] = [23.0, 38.0];"; failure=false) == "@test +(interval(10.0, 20.0), interval(13.0, 17.0)) == Interval(23.0, 38.0)"


    # tests with NaN
    @test parse_command("rad [empty] = NaN;") == "@test isnan(radius(emptyinterval()))"

    # two outputs
    @test parse_command("midRad [0.0,2.0] = 1.0 1.0;") == "@test midpoint_radius(interval(0.0,2.0))[1] == 1.0 && midpoint_radius(interval(0.0,2.0))[2] == 1.0"

    # texts
    @test parse_command("""b-textToInterval "[1.e-3, 1.1e-3]" = [0X4.189374BC6A7ECP-12, 0X4.816F0068DB8BCP-12];""") == "@test @interval(\"[1.e-3, 1.1e-3]\") == Interval(0x4.189374BC6A7ECP-12, 0x4.816F0068DB8BCP-12)"
    @test parse_command("""d-textToInterval "[entire]" = [-infinity, +infinity]_dac;""") == "@test @decorated(\"[entire]\") == DecoratedInterval(Interval(-Inf, +Inf), dac) && decoration(@decorated(\"[entire]\")) == decoration(DecoratedInterval(Interval(-Inf, +Inf), dac))"
    @test parse_command("""d-textToInterval "[nai]" = [nai];""") == "@test isnai(@decorated(\"[nai]\"))"
end
