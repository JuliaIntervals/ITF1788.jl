# ITF1788

[![Build Status](https://github.com/juliaintervals/ITF1788.jl/workflows/CI/badge.svg)](https://github.com/juliaintervals/ITF1788.jl/actions)
[![Coverage](https://codecov.io/gh/juliaintervals/ITF1788.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/juliaintervals/ITF1788.jl)

This package is a parser of the Interval Tests Libraries (ITL) testsuite, created by Oliver Heimlich and available [here](https://github.com/oheim/ITF1788). The tests are to verify whether an interval arithmetic implementation is complying to the IEEE 1788-2015 standard for interval arithmetic. This package converts the test suite to tests in Julia, which can be used to test [IntervalArithmetic.jl](https://github.com/juliaintervals/intervalarithmetic.jl)

## How to use

Install and import the package with 

```julia
julia> using Pkg; Pkg.add("ITF1788") # only once to install
julia> using ITF1788
```

then run

```
julia> generate()
```

and this function will convert all the test into Julia tests, actually check the tests and mark as broken those not passing.

For example, if the original `.itl` file had a line like

```
add [1.0, 2.0] [1.0, 2.0] = [2.0, 4.0]
```

this will become
```julia
@test +(interval(1.0, 2.0), interval(1.0, 2.0)) == Interval(2.0, 4.0)
```

if the test is successful and
```
@test_broken +(interval(1.0, 2.0), interval(1.0, 2.0)) == Interval(2.0, 4.0)
```

if the test is unsuccessful.

If you do not want to actually run the test and mark the broken tests, you can run
`generate(; failure=false)`. This will use the macro `@test` for all tests regardless of whether they succeed or not.

By default, all test files are created into a folder `test_ITF1788` in your current directory. You can change the output directory with the
keyword `output`, e.g. `generate(; output="mydirectory")`.

The function will also create a `run_ITF1788.jl` which includes all the tests files.

# Note

Tests for reverse functions are missing, but coming soon...

## Author

- [Luca Ferranti](https://github.com/lucaferranti)



