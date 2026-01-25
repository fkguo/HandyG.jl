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

