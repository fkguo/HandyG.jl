"""
    HandyG

Julia bindings for the Fortran library [handyG](https://gitlab.com/mule-tools/handyg).

The main entrypoints are:

- `G`, `G!`: scalar evaluation in superflat / flat / condensed form
- `G_batch!`: batch evaluation for large workloads (fixed-depth column-major matrices)
- `inum`: `i0±` prescription inputs (structure-of-arrays, allocation-free hot paths)

See `docs/src/` for the user manual.
"""
module HandyG

using Artifacts
using Libdl

export INum, INumVec, INumMat, inum
export clearcache, clearcache!
export set_mpldelta!, set_lidelta!, set_hoelder_circle!, set_options!
export G, G!, G_batch!

include("types.jl")
include("lib.jl")
include("ffi.jl")
include("api.jl")

end # module HandyG
