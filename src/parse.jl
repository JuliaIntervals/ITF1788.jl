function parse_block(block; failure=true, test_warn=true)

    bname = match(r"^\s*testcase\s+(\S+)\s+\{\s*$", block[1])[1]

    testset = """@testset "$bname" begin
            """
    ind = "    "
    for i in 2:length(block)-1
        line = strip(block[i])
        (isempty(line) || startswith(line, "//")) && continue
        command = parse_command(line; failure=failure, test_warn=test_warn)
        testset = """$testset
        $ind$command
        """
    end
    testset = """$testset
            end

            """
end

"""

This function parses a line into julia code, e.g.

```
add [1, 2] [1, 2] = [2, 4]
```

is parsed into
```
@test +(Interval(1, 2), Interval(1, 2)) === Interval(2, 4)
```
"""
function parse_command(line; failure=true, test_warn=true)
    # extract parts in line
    m = match(r"^(.+)=(.+);$", line)
    lhs = m[1]
    rhs = m[2]
    rhs = split(rhs, "signal")
    warn = length(rhs) > 1 ? rhs[2] : ""
    rhs = rhs[1]

    lhs = parse_lhs(lhs)
    rhs = parse_rhs(rhs)

    expr = build_expression(lhs, rhs)
    if failure
        try
            res = eval(Meta.parse(expr))
            command = res ? "@test $expr" : "@test_skip $expr"
        catch
            command = "@test_skip $expr"
        end
    else
        command = "@test $expr"
    end
    if test_warn
        command = isempty(warn) ? command : "@test_logs (:warn, ) $command"
    end
    return command
end

function parse_lhs(lhs)
    lhs = strip(lhs)
    m =  match(r"^(\S+) (.+)$", lhs)
    fname = m[1]
    args = m[2]

    #special case, input text
    fname == "b-textToInterval" && return "@interval($args)"
    fname == "d-textToInterval" && return "@decorated($args)"

    # input numbers
    args = replace(args, "infinity" => "Inf")
    args = replace(args, "X" => "x")
    if fname == "b-numsToInterval"
        args = join(split(args), ',')
        return "interval($args)"
    end

    if fname == "d-numsToInterval"
        args = join(split(args), ',')
        return "DecoratedInterval($args)"
    end

    # input intervals
    rx = r"\[([^\]]+)\](?:_(\w+))?"
    for m in eachmatch(rx, args)
        args = replace(args, m.match => parse_interval(m[1], m[2]))
    end
    args = replace(args, " " => ", ")
    args = replace(args, ",," => ",")
    args = replace(args, "{" => "[")
    args = replace(args, "}" => "]")
    return functions[fname](args)

end

function parse_rhs(rhs)
    rhs = strip(rhs)
    rhs = replace(rhs, "infinity" => "Inf")
    rhs = replace(rhs, "X" => "x")
    if '[' ∉ rhs # one or more scalar/bolean values separated by space
        return split(rhs)
    else # one or more intervals
        rx = r"\[([^\]]+)\](?:_(\w+))?"
        ivals = [parse_interval(m[1], m[2]; check=false) for m in eachmatch(rx, rhs)]
        return ivals
    end
end

function parse_interval(ival, dec; check=true)

    ival == "nai" && return "nai()"
    if ival == "entire"
        ival =  "entireinterval()"
    elseif ival == "empty"
        ival = "emptyinterval()"
    else
        ival = check ? "interval($ival)" : "Interval($ival)"
    end
    isnothing(dec) || (ival = "DecoratedInterval($ival, $dec)")
    return ival
end

function build_expression(lhs, rhs::AbstractString)
    rhs == "nai()" && return "isnai($lhs)"
    rhs == "NaN" && return "isnan($lhs)"
    return "$lhs === $rhs"
end

function build_expression(lhs, rhs::Vector)
    length(rhs) == 1 && return build_expression(lhs, rhs[1])
    expr = [build_expression(lhs*"[$i]", r) for (i, r) in enumerate(rhs)]
    return join(expr, " && ")
end
