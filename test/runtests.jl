using Test
using HandyG

@testset "HandyG.jl" begin
    let
        @test HandyG.inum(1.0).i0 == Int8(1)

        HandyG.clearcache()

        # Scalar API (superflat / flat / condensed)
        g1 = [1.0, 0.0, 0.5, 0.3]
        @test HandyG.G(g1) ≈ (0.128388454427768 + 0im) atol = 1e-12 rtol = 0

        g2 = [1.0, 2.0, 1.0]
        @test HandyG.G(g2) ≈ (-0.8224670334241131 + 0im) atol = 1e-12 rtol = 0

        z = [1.0, 0.0, 0.5]
        y = 0.3
        @test HandyG.G(z, y) ≈ HandyG.G(g1) atol = 1e-12 rtol = 0

        m = Cint[1, 2]
        zc = [1.0, 0.5]
        @test HandyG.G(m, zc, y) ≈ HandyG.G(g1) atol = 1e-12 rtol = 0

        # Convenience integer inputs (may allocate conversion buffers)
        @test HandyG.G([1, 2], zc, y) ≈ HandyG.G(m, zc, y) atol = 1e-12 rtol = 0

        # i0 prescription (manual SoA)
        x = 0.3
        zvals = ComplexF64[1, 0, 5]
        yval = ComplexF64(1 / x, 0)
        z_i0 = Int8[1, 1, 1]
        res4 = HandyG.G(HandyG.inum(zvals, z_i0), HandyG.inum(yval, 1))
        @test res4 ≈ (-0.9612791924920746 - 0.662887910801087im) atol = 1e-12 rtol = 0

        z_i0 = Int8[-1, 1, 1]
        res5 = HandyG.G(HandyG.inum(zvals, z_i0), HandyG.inum(yval, 1))
        @test res5 ≈ (-0.9612791924920746 + 0.662887910801087im) atol = 1e-12 rtol = 0

        # Convenience i0 element type (may allocate)
        @test HandyG.G(HandyG.inum(zvals, [-1, 1, 1]), HandyG.inum(yval, 1)) ≈ res5 atol = 1e-12 rtol = 0

        # condensed i0
        zc2 = ComplexF64[1, 5]
        zc2_i0 = Int8[-1, 1]
        @test HandyG.G(Cint[1, 2], HandyG.inum(zc2, zc2_i0), HandyG.inum(yval, 1)) ≈ res5 atol = 1e-12 rtol = 0

        # Batch API
        out = Vector{ComplexF64}(undef, 2)

        depth_max = 4
        gmat = zeros(Float64, depth_max, 2)
        gmat[:, 1] = g1
        gmat[1:3, 2] = g2
        len_super = Cint[4, 3]
        HandyG.G_batch!(out, gmat, len_super)
        @test out[1] ≈ HandyG.G(g1) atol = 1e-12 rtol = 0
        @test out[2] ≈ HandyG.G(g2) atol = 1e-12 rtol = 0

        # Convenience len element type (may allocate)
        HandyG.G_batch!(out, gmat, [4, 3])
        @test out[1] ≈ HandyG.G(g1) atol = 1e-12 rtol = 0
        @test out[2] ≈ HandyG.G(g2) atol = 1e-12 rtol = 0

        zmat = zeros(Float64, 3, 2)
        zmat[:, 1] = z
        zmat[1:2, 2] = [1.0, 2.0]
        yvec = ComplexF64[y, 1.0]
        len_flat = Cint[3, 2]
        HandyG.G_batch!(out, zmat, yvec, len_flat)
        @test out[1] ≈ HandyG.G(z, y) atol = 1e-12 rtol = 0
        @test out[2] ≈ HandyG.G([1.0, 2.0], 1.0) atol = 1e-12 rtol = 0

        # Convenience len element type (may allocate)
        HandyG.G_batch!(out, zmat, yvec, [3, 2])
        @test out[1] ≈ HandyG.G(z, y) atol = 1e-12 rtol = 0
        @test out[2] ≈ HandyG.G([1.0, 2.0], 1.0) atol = 1e-12 rtol = 0

        # Allocation gates (after warmup)
        HandyG.G(g1)
        @test (@allocated HandyG.G(g1)) == 0

        HandyG.G(z, y)
        @test (@allocated HandyG.G(z, y)) == 0

        HandyG.G(m, zc, y)
        @test (@allocated HandyG.G(m, zc, y)) == 0

        HandyG.G_batch!(out, gmat, len_super)
        @test (@allocated HandyG.G_batch!(out, gmat, len_super)) == 0

        HandyG.G_batch!(out, zmat, yvec, len_flat)
        @test (@allocated HandyG.G_batch!(out, zmat, yvec, len_flat)) == 0
    end
end
