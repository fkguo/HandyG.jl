# Batch API

For large workloads, `G_batch!` evaluates many GPLs in one call without allocating.

This wrapper uses **fixed-depth column-major matrices**:

- Inputs are `(depth_max, N)` matrices (Julia is column-major)
- A `len::Vector{Cint}` tells how many entries are valid in each column
- Results are written into `out::Vector{ComplexF64}` of length `N`

`len` must be `Vector{Cint}` for allocation-free hot paths. For convenience you may pass other integer element types (e.g. `Vector{Int}`); `HandyG.jl` converts to `Cint` using an internal scratch buffer. After warmup, this can be allocation-free; see [Manual → Performance Notes](performance.md).

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

## Condensed batch

Condensed (zero-compressed) inputs use a matrix of partial weights `m` alongside
the parameter matrix `z`. Both have the same shape `(depth_max, N)`, and `len`
gives the active depth per column.

```julia
using HandyG

depth_max = 2
N = 2

m = zeros(Cint, depth_max, N)
z = zeros(Float64, depth_max, N)
len = Cint[2, 1]
y = fill(ComplexF64(0.3, 0.0), N)

# Rows beyond len[j] in each column are ignored by the library.
#
# Column 1: m=[1,2], z=[1.0,0.5]  => G_{1,2}(1.0,0.5; 0.3) = G(1.0,0,0.5; 0.3)
m[:, 1] = Cint[1, 2]
z[:, 1] = [1.0, 0.5]

# Column 2: m=[3], z=[2.0]        => G_3(2.0; 0.3) = G(0,0,2.0; 0.3)
m[1, 2] = Cint(3)
z[1, 2] = 2.0

out = Vector{ComplexF64}(undef, N)

G_batch!(out, m, z, y, len)
```

## Notes

- Inputs must be **contiguous column-major** (stride-1 first dimension, contiguous columns). Views like `@view` may fail the checks unless they are contiguous.
- `G_batch!` is the preferred interface for throughput and to avoid per-call overhead.
