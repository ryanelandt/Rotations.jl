using Rotations
using BenchmarkTools
import Base.Iterators: product
import Compat.Random: srand

const T = Float64

const suite = BenchmarkGroup()
srand(1)

suite["conversions"] = BenchmarkGroup()
rotationtypes = (RotMatrix3{T}, Quat{T}, SPQuat{T}, AngleAxis{T}, RodriguesVec{T})
for (from, to) in product(rotationtypes, rotationtypes)
    if from != to
        name = if VERSION < v"0.7.0-"
            "$(string(from)) -> $(string(to))"
        else
            "Rotations.$(string(from)) -> Rotations.$(string(to))"
        end
        # use eval here because of https://github.com/JuliaCI/BenchmarkTools.jl/issues/50#issuecomment-318673288
        suite["conversions"][name] = eval(:(@benchmarkable convert($to, rot) setup = rot = rand($from)))
    end
end

suite["composition"] = BenchmarkGroup()
suite["composition"]["RotMatrix{3} * RotMatrix{3}"] = @benchmarkable(
    r1 * r2,
    setup = (r1 = rand(RotMatrix3{T}); r2 = rand(RotMatrix3{T}))
)

paramspath = joinpath(@__DIR__, "benchmarkparams.json")
if isfile(paramspath)
    loadparams!(suite, BenchmarkTools.load(paramspath)[1], :evals, :samples);
else
    tune!(suite, verbose = true)
    BenchmarkTools.save(paramspath, params(suite))
end

results = run(suite, verbose=true)
for (groupname, groupresults) in results
    println("Group: $groupname")
    for result in groupresults
        println("$(first(result)):")
        display(minimum(last(result)))
        println()
    end
    println()
end
