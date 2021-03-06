versioninfo()

using ApproxFun, Base.Test
    import ApproxFun: Infinity, ∞

println("Helper tests")
@test ApproxFun.interlace!([-1.0],0) == [-1.0]
@test ApproxFun.interlace!([1.0,2.0],0) == [2.0,1.0]
@test ApproxFun.interlace!([1,2,3],0) == [2,1,3]
@test ApproxFun.interlace!([1,2,3,4],0) == [3,1,4,2]

@test ApproxFun.interlace!([-1.0],1) == [-1.0]
@test ApproxFun.interlace!([1.0,2.0],1) == [1.0,2.0]
@test ApproxFun.interlace!([1,2,3],1) == [1,3,2]
@test ApproxFun.interlace!([1,2,3,4],1) == [1,3,2,4]

@test exp(im*π/4)*∞ == Inf+im*Inf
@test exp(im*π/4)+∞ == ∞
@test ∞ ≠ 1

@test maximum([1,∞]) == ∞
@test minimum([1,∞]) == 1

@test Infinity(true)+Infinity(true) == Infinity(true)
@test Infinity(false)+Infinity(false) == Infinity(false)
@test Infinity(true)+1 == Infinity(true)
@test Infinity(false)+1 == Infinity(false)

@test ApproxFun.interlace(collect(6:10),collect(1:5)) == ApproxFun.interlace!(collect(1:10),0)
@test ApproxFun.interlace(collect(1:5),collect(6:10)) == ApproxFun.interlace!(collect(1:10),1)

@test maximum(ApproxFun.repeated(1)) == 1
@test minimum(1:∞) == 1
@test minimum(ApproxFun.flatten(([2.0],1:ApproxFun.∞))) == 1

cumsum(ApproxFun.repeated(true)) == 1:ApproxFun.∞
cumsum(ApproxFun.repeated(2)) == 2:2:ApproxFun.∞

@test 2*(1:∞) == 2:2:∞
@test 2+(1:∞) == 3:∞

# BlockInterlacer tests
@test cache(ApproxFun.BlockInterlacer((1:∞,[2],[2])))[1:6] ==
    [(1,1),(2,1),(2,2),(3,1),(3,2),(1,2)]

@test collect(ApproxFun.BlockInterlacer(([2],[2],[2]))) ==
    [(1,1),(1,2),(2,1),(2,2),(3,1),(3,2)]


# TODO: Tensorizer tests

println("Domain tests")

@test !in(0.45-0.65im,Interval())
@test cumsum(ApproxFun.Flatten(([3],ApproxFun.repeated(2)))).it[2]==ApproxFun.Count(5,2)
@test reverse(Arc(1,2,(0.1,0.2))) == Arc(1,2,(0.2,0.1))
@test in(0.1,PeriodicInterval(2π,0))

@test isambiguous(convert(ApproxFun.Point,ApproxFun.AnyDomain()))
@test isambiguous(ApproxFun.Point(ApproxFun.AnyDomain()))

@test ApproxFun.AnySegment() == ApproxFun.AnySegment()
@test ApproxFun.Point(NaN) == ApproxFun.Point(NaN)

@time include("MatrixTest.jl")


println("Fun tests")
@time include("ClenshawTest.jl")
@time include("ChebyshevTest.jl")
@time include("FourierTest.jl")
@time include("ComplexTest.jl")
@time include("NumberTypeTest.jl")
@time include("broadcastingtest.jl")
println("Operator tests")
@time include("OperatorTest.jl")
println("ODE tests")
@time include("ODETest.jl")
println("Vector tests")
@time include("VectorTest.jl")
println("Singularities tests")
@time include("SingularitiesTest.jl")
println("Integral Equations tests")
@time include("IntegralEquationsTest.jl")
println("Spaces tests")
@time include("SpacesTest.jl")
println("Jacobi tests")
@time include("JacobiTest.jl")


println("Extras tests")
@time include("ETDRK4Test.jl")
@time include("ExtrasTest.jl")

println("Multivariate tests")
@time include("MultivariateTest.jl")
println("PDE tests")
@time include("PDETest.jl")
