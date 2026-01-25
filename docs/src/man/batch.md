# Batch API

For large workloads, `G_batch!` evaluates many GPLs in one call without allocating.

This wrapper uses **fixed-depth column-major matrices**:

- Inputs are `(depth_max, N)` matrices (Julia is column-major)
- A `len::Vector{Cint}` tells how many entries are valid in each column
- Results are written into `out::Vector{ComplexF64}` of length `N`

`len` must be `Vector{Cint}` for allocation-free hot paths. For convenience you may pass other integer element types (e.g. `Vector{Int}`); `HandyG.jl` converts to `Cint` using an internal scratch buffer that may allocate when it grows.

## Superflat batch

```julia
using HandyG

depth_max = 4
N = 2

g = zeros(Float64, depth_max, N)
len = Cint[4, 3]

g[:, 1] = [1.0, 0.0, 0.5, 0.3]   # z..., y
g[1:3, 2] = [1.0, 2.0, 1.0]      # z..., y (len=3)

out = Vector{ComplexF64}(undef, N)
G_batch!(out, g, len)
```

## Flat batch

```julia
using HandyG

depth_max = 3
N = 2

z = zeros(Float64, depth_max, N)
len = Cint[3, 2]
z[:, 1] = [1.0, 0.0, 0.5]
z[1:2, 2] = [1.0, 2.0]

y = ComplexF64[0.3 + 0im, 1.0 + 0im]
out = Vector{ComplexF64}(undef, N)

G_batch!(out, z, y, len)
```

## Notes

- Inputs must be **contiguous column-major** (stride-1 first dimension, contiguous columns). Views like `@view` may fail the checks unless they are contiguous.
- `G_batch!` is the preferred interface for throughput and to avoid per-call overhead.
