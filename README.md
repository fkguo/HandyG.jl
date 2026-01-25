# HandyG.jl

Julia bindings for the Fortran library **handyG** (numerical evaluation of generalised polylogarithms).

## Status

Work in progress. This repo will provide:
- A Julia API close to the upstream Fortran calling style
- Cross-platform binaries (macOS/Linux/Windows) via BinaryBuilder/JLL
- Double + quad (`--quad`) builds

Currently implemented (double precision, local build):
- Scalar calls via `G(...)` (superflat / flat / condensed)
- Batch calls via `G_batch!(out, ...)` (fixed-depth column-major matrices + `len`)
- `i0±` prescription via SoA wrappers: `inum(c, i0)`

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

## License

GPL-3.0 (same as upstream handyG). See `LICENSE`.
