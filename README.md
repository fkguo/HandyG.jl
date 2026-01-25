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

This package can be installed directly from GitHub:

```julia
using Pkg
Pkg.add(url="https://github.com/fkguo/HandyG.jl.git")
```

### Provide `libhandyg`

`HandyG.jl` requires the upstream shared library `libhandyg` to be available at runtime.

- **Local build (developer workflow):**
  ```bash
  # expects the upstream handyG repo as a sibling: ../handyg
  bash deps/build_local.sh
  ```
  Override the upstream source path:
  ```bash
  export HANDYG_SRC=/path/to/handyG/src
  bash deps/build_local.sh
  ```
- **Point to an existing build:**
  ```bash
  export HANDYG_LIB=/abs/path/to/libhandyg.so    # Linux
  export HANDYG_LIB=/abs/path/to/libhandyg.dylib # macOS
  export HANDYG_LIB=C:\\path\\to\\libhandyg.dll  # Windows
  ```
- **In progress:** BinaryBuilder/JLL distribution via Yggdrasil (PR: https://github.com/JuliaPackaging/Yggdrasil/pull/13008).

## Status

Implemented (double precision):

- Scalar calls: `G(...)` and `G!(out, ...)` (superflat / flat / condensed)
- Batch calls: `G_batch!(out, ...)` (fixed-depth column-major matrices + `len`)
- Explicit `i0±` prescription: `inum(...)` (structure-of-arrays)

Planned:

- Cross-platform binaries via BinaryBuilder/JLL (pending Yggdrasil merge)
- Quad builds (`--quad`) (temporary strategy: Windows may remain double-only)

## Library discovery

At runtime `HandyG.jl` looks for `libhandyg` in this order:

1. `ENV["HANDYG_LIB"]` (absolute path to `libhandyg.so/.dylib/.dll`)
2. An artifact entry in `Artifacts.toml` (reserved for future JLL integration)
3. Local dev build: `deps/usr/lib/`
4. System library search paths

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
