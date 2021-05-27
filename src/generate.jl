"""
    generate(filename; ofolder="", failure=false)

Generates the julia tests from the file filename. The tests in filename must be written
using the ITL domain specific language. The tests are written in a .jl file with the same
name of filename. The folder where to save the output file is specifified

If failure=true, than each test is also executed before printing to the target file. If the
test fails, then the test is generated as ´@test_broken`.
"""
function generate(filename; failure=true, output="test_ITF1788")

    # read file
    src = joinpath(@__DIR__, "itl", filename)
    f = open(src)
    lines = readlines(f)
    close(f)

    # file where to Write
    dest = joinpath(output, filename[1:end-4]*".jl")
    mkpath(output)
    f = open(dest; write=true)

    # where testcase blocks start
    rx_start = r"^\s*testcase\s+\S+\s+\{\s*$"
    rx_end = r"^\s*\}\s*$"
    block_start = findall(x -> occursin(rx_start, x), lines)
    block_end = findall(x -> occursin(rx_end, x), lines)

    # check opening and closing blocks match
    length(block_start) == length(block_end) || throw(ArgumentError("opening and closing braces not not much in $filename"))

    for (bstart, bend) in zip(block_start, block_end)
        testset = parse_block(lines[bstart:bend]; failure=failure)
        write(f, testset)
    end

    close(f)
    nothing
end

function generate(; failure=true, output="test_ITF1788")

    files = ("atan2.itl",
            "c-xsc.itl",
            "fi_lib.itl",
            "ieee1788-constructors.itl",
            "ieee1788-exceptions.itl",
            "libieeep1788_bool.itl",
            "libieeep1788_cancel.itl",
            "libieeep1788_class.itl",
            "libieeep1788_elem.itl",
            "libieeep1788_num.itl",
            "libieeep1788_overlap.itl",
            "libieeep1788_rec_bool.itl",
            "libieeep1788_reduction.itl",
            "libieeep1788_set.itl",
            "mpfi.itl",
    )
    for file in files
        generate(file; failure=failure, output=output)
    end

    f = open(joinpath(output, "run_ITF1788.jl"); write=true)
    for file in files
        write(f, "include($(file[1:end-4]).jl)\n")
    end
    close(f)
end
