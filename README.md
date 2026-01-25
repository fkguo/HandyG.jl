# HandyG.jl

Julia bindings for the Fortran library **handyG** (numerical evaluation of generalised polylogarithms).

Upstream: https://gitlab.com/mule-tools/handyg  
Paper: https://arxiv.org/abs/1909.01656

## Documentation

- Manual (Markdown source): `docs/src/index.md`
- Build HTML docs locally: `julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate(); include("docs/make.jl")'`

## Status

Implemented (double precision):

- Scalar calls: `G(...)` and `G!(out, ...)` (superflat / flat / condensed)
- Batch calls: `G_batch!(out, ...)` (fixed-depth column-major matrices + `len`)
- Explicit `i0±` prescription: `inum(...)` (structure-of-arrays)

Planned:

- Cross-platform binaries via BinaryBuilder/JLL (and Yggdrasil)
- Quad builds (`--quad`) (temporary strategy: Windows may remain double-only)

## Development quickstart (local build)

This builds a shared `libhandyg` into `deps/usr/lib/` and uses it automatically.

```bash
# assumes you have the upstream handyG repo as a sibling ../handyg
bash deps/build_local.sh

julia -e 'using Pkg; Pkg.activate("."); using HandyG; println(G([1.0,0.0,0.5,0.3]))'
```

Override the handyG source path:

```bash
HANDYG_SRC=/path/to/handyG/src bash deps/build_local.sh
```

## Library discovery

At runtime `HandyG.jl` looks for `libhandyg` in this order:

1. `ENV["HANDYG_LIB"]` (absolute path to `libhandyg.so/.dylib/.dll`)
2. An artifact entry in `Artifacts.toml` (reserved for future JLL integration)
3. Local dev build: `deps/usr/lib/`
4. System library search paths

## Quick usage examples

```julia
using HandyG

# superflat form (z..., y)
G([1.0, 0.0, 0.5, 0.3])

# flat form
G([1.0, 0.0, 0.5], 0.3)

# condensed form
G(Cint[1, 2], [1.0, 0.5], 0.3)

# explicit i0± prescription (SoA)
z = ComplexF64[1, 0, 5]
z_i0 = Int8[+1, +1, +1]
y = inum(ComplexF64(1/0.3, 0), +1)
G(inum(z, z_i0), y)
```

## License

GPL-3.0 (same as upstream handyG). See `LICENSE`.
