# Calling Conventions

Upstream handyG exposes `G(...)` in multiple “shapes” (superflat / flat / condensed). `HandyG.jl` keeps the same ideas, implemented via Julia multiple dispatch.

All APIs below are **double precision** currently (`Float64` / `ComplexF64`).

Inputs should be `Float64` / `ComplexF64` arrays for performance and to avoid implicit conversions.

## Superflat form

The last entry is `y`, the previous entries are `z₁, …, zₙ`:

```julia
using HandyG

g = [1.0, 0.0, 0.5, 0.3]  # z..., y
val = G(g)
```

## Flat form

```julia
z = [1.0, 0.0, 0.5]
y = 0.3
val = G(z, y)
```

Complex inputs:

```julia
z = ComplexF64[1, 0, 0.5, 1im]
y = ComplexF64(0.3, 0.0)
val = G(z, y)
```

## Condensed form

In condensed form, `m` encodes runs of trailing zeros. (See the upstream paper/README for the definition; this wrapper follows the upstream semantics.)

```julia
m = Cint[1, 2]
z = [1.0, 0.5]
y = 0.3
val = G(m, z, y)
```

For convenience you may also pass `m::Vector{Int}` (or other integer types); `HandyG.jl` will convert to the C-ABI element type (`Cint`). This conversion may allocate when the internal scratch buffer grows. For allocation-free hot paths, prefer `Cint[...]`.

## In-place scalar evaluation: `G!`

For tight loops, write into a preallocated `Ref{ComplexF64}`:

```julia
out = Ref{ComplexF64}()
G!(out, [1.0, 0.0, 0.5, 0.3])
val = out[]
```

For batch evaluation, see [Manual → Batch API](batch.md).

## Fortran examples → Julia equivalents

The upstream README contains a small Fortran example program. Here are direct Julia equivalents:

```julia
using HandyG

x = 0.3

# flat form with integers (use Float64 in Julia)
res1 = G([1.0, 2.0, 1.0])

# very flat (superflat) form
res2 = G([1.0, 0.0, 0.5, x])

# same as flat form
res2b = G([1.0, 0.0, 0.5], x)

# condensed form
res2c = G(Cint[1, 2], [1.0, 0.5], x)
```
