using Clustering
using Distances: SqEuclidean, pairwise
using Test

@testset "seeding" begin

Random.seed!(34568)

@test RandSeedAlg <: SeedingAlgorithm
@test KmppAlg <: SeedingAlgorithm
@test KmCentralityAlg <: SeedingAlgorithm

alldistinct(x::Vector{Int}) = (length(Set(x)) == length(x))

function min_interdist(X::Matrix)
    dists = pairwise(SqEuclidean(), X)
    n = size(X, 2)
    r = Inf
    for i = 1:n, j = 1:n
        if i != j && dists[i,j] < r
            r = dists[i,j]
        end
    end
    return r
end


d = 3
n = 100
k = 5
X = rand(d, n)
C = pairwise(SqEuclidean(), X)

md0 = min_interdist(X)

@testset "RandSeed" begin
    iseeds = initseeds(RandSeedAlg(), X, k)
    @test length(iseeds) == k
    @test alldistinct(iseeds)

    iseeds = initseeds_by_costs(RandSeedAlg(), C, k)
    @test length(iseeds) == k
    @test alldistinct(iseeds)

    R = copyseeds(X, iseeds)
    @test isa(R, Matrix{Float64})
    @test R == X[:, iseeds]
end

@testset "Kmpp" begin
    iseeds = initseeds(KmppAlg(), X, k)
    @test length(iseeds) == k
    @test alldistinct(iseeds)

    iseeds = initseeds_by_costs(KmppAlg(), C, k)
    @test length(iseeds) == k
    @test alldistinct(iseeds)

    @test min_interdist(X[:, iseeds]) > 20 * md0

    iseeds = kmpp(X, k)
    @test length(iseeds) == k
    @test alldistinct(iseeds)

    iseeds = kmpp_by_costs(C, k)
    @test length(iseeds) == k
    @test alldistinct(iseeds)
end

@testset "Kmcentrality" begin
    iseeds = initseeds(KmCentralityAlg(), X, k)
    @test length(iseeds) == k
    @test alldistinct(iseeds)

    iseeds = initseeds_by_costs(KmCentralityAlg(), C, k)
    @test length(iseeds) == k
    @test alldistinct(iseeds)

    @test min_interdist(X[:, iseeds]) > 2 * md0
end

end
