# HandyG.jl

Julia bindings for the Fortran library [handyG](https://gitlab.com/mule-tools/handyg) (rapid numerical evaluation of generalized polylogarithms / GPLs).

This documentation focuses on:

- A Julia API that stays close to the upstream Fortran calling conventions
- Allocation-free hot paths (`G`, `G!`, `G_batch!`) after warmup
- Cross-platform binaries via `HandyG_jll` (BinaryBuilder/Yggdrasil)

## Where to start

- Installation: see [Manual → Installation](man/installation.md)
- Definitions and GPL notation: see [Manual → Definitions & Notation](man/definitions.md)
- Calling conventions: see [Manual → Calling Conventions](man/calling.md)
- `i0±` prescription: see [Manual → i0 Prescription](man/i0.md)
- Batch API for large workloads: see [Manual → Batch API](man/batch.md)
- Full API reference: see [API Reference](api.md)

## Quick start

```julia
using HandyG

# superflat form (z..., y)
val = G([1.0, 0.0, 0.5, 0.3])
```
