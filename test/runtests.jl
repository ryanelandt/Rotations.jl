using Compat
using Compat.Test
using Compat.LinearAlgebra
using Rotations
using StaticArrays

import Compat.Random: srand

# Check that there are no ambiguities beyond those present in StaticArrays
ramb = detect_ambiguities(Rotations, Base, Core)
samb = detect_ambiguities(StaticArrays, Base, Core)
@test isempty(setdiff(ramb, samb))

# TODO test mean()

include("util_tests.jl")
include("2d.jl")
include("rotation_tests.jl")
include("derivative_tests.jl")

include(joinpath(@__DIR__, "..", "perf", "runbenchmarks.jl"))
