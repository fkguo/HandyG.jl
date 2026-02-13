# HandyG.jl

[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://fkguo.github.io/HandyG.jl/dev/)

Julia bindings for the Fortran library **handyG** (numerical evaluation of generalised polylogarithms).

Upstream: https://gitlab.com/mule-tools/handyg  
Paper: https://arxiv.org/abs/1909.01656

## Documentation

- Online docs (dev): https://fkguo.github.io/HandyG.jl/dev/
- Manual source: `docs/src/index.md`

Build HTML docs locally:

```bash
julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate(); include("docs/make.jl")'
```

## Installation

`HandyG.jl` is registered in Julia General Registry.

```text
julia> ]
pkg> add HandyG
```

or:

```julia
using Pkg
Pkg.add("HandyG")
```

For development from the latest repository state:

```julia
using Pkg
Pkg.add(url="https://github.com/fkguo/HandyG.jl.git")
```

`HandyG.jl` depends on `HandyG_jll`, which provides prebuilt `libhandyg` binaries via
BinaryBuilder/Yggdrasil, so end users do not need a local Fortran toolchain.

## Status

Implemented (double precision):

- Scalar calls: `G(...)` and `G!(out, ...)` (superflat / flat / condensed)
- Batch calls: `G_batch!(out, ...)` (fixed-depth column-major matrices + `len`)
- Explicit `i0±` prescription: `inum(...)` (structure-of-arrays)
- Cross-platform binaries via `HandyG_jll` (BinaryBuilder/Yggdrasil)

Not supported:

- Quad builds (`--quad`): this wrapper is currently double-only (`Float64` / `ComplexF64`)

## Quick usage examples

```julia
using HandyG

# (optional) clear handyG internal caches
clearcache!()

# superflat form (z..., y)
G([1.0, 0.0, 0.5, 0.3])

# flat form
G([1.0, 0.0, 0.5], 0.3)

# condensed form
G(Cint[1, 2], [1.0, 0.5], 0.3)

# convenience: `m` can be `Vector{Int}`; converted to `Cint` via an internal scratch buffer
m = [1, 2]
G(m, [1.0, 0.5], 0.3)

# fastest: preconvert to `Cint` once (avoids per-call conversion)
const m_c = Cint.(m)
G(m_c, [1.0, 0.5], 0.3)

# explicit i0± prescription (SoA)
z = ComplexF64[1, 0, 5]
z_i0 = Int8[+1, +1, +1]
y = inum(ComplexF64(1/0.3, 0), +1)
G(inum(z, z_i0), y)
```

## License

GPL-3.0 (same as upstream handyG). See `LICENSE`.
