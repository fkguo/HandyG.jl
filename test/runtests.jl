using Test
using HandyG

@testset "HandyG.jl" begin
    @test HandyG.inum(1.0).i0 == Int8(1)
end

