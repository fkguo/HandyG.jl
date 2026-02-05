const _LIB_PATH = Ref{String}("")
const _LIB_HANDLE = Ref{Ptr{Nothing}}(C_NULL)

const _HANDYG_JLL_PKGID = Base.PkgId(Base.UUID("176cd8ec-bef4-5d25-a3d7-2797db4e996d"), "HandyG_jll")

@inline function _lib_filename()
    if Sys.iswindows()
        return "libhandyg.dll"
    elseif Sys.isapple()
        return "libhandyg.dylib"
    else
        return "libhandyg.so"
    end
end

@inline function _try_libhandyg_from_jll()
    try
        jll = Base.require(_HANDYG_JLL_PKGID)
        libpath = String(getproperty(jll, :libhandyg))
        isfile(libpath) ? libpath : nothing
    catch
        nothing
    end
end

function _find_libhandyg()
    if haskey(ENV, "HANDYG_LIB")
        return ENV["HANDYG_LIB"]
    end

    local_dev = normpath(joinpath(@__DIR__, "..", "deps", "usr", "lib", _lib_filename()))
    if isfile(local_dev)
        return local_dev
    end

    jll = _try_libhandyg_from_jll()
    jll === nothing || return jll

    artifacts_toml = normpath(joinpath(@__DIR__, "..", "Artifacts.toml"))
    if isfile(artifacts_toml)
        hash = Artifacts.artifact_hash("handyg", artifacts_toml)
        if hash !== nothing
            artdir = Artifacts.artifact_path(hash)
            if Sys.iswindows()
                candidate = joinpath(artdir, "bin", _lib_filename())
                isfile(candidate) && return candidate
                candidate = joinpath(artdir, "lib", _lib_filename())
                isfile(candidate) && return candidate
            else
                candidate = joinpath(artdir, "lib", _lib_filename())
                isfile(candidate) && return candidate
            end
        end
    end

    found = Libdl.find_library(["handyg", "libhandyg"], String[])
    if !isempty(found)
        return found
    end

    error("HandyG: libhandyg not found. Install `HandyG_jll` (normally pulled in automatically), set ENV[\"HANDYG_LIB\"], or build a dev copy via `bash deps/build_local.sh`.")
end

@inline function _ensure_libhandyg!()
    if !isempty(_LIB_PATH[])
        return _LIB_PATH[]
    end
    libpath = _find_libhandyg()
    _LIB_HANDLE[] = Libdl.dlopen(libpath)
    _LIB_PATH[] = libpath
    return libpath
end

"""
    libhandyg_path() -> String

Return the filesystem path of the loaded `libhandyg` shared library.

Returns `\"\"` if the library has not been loaded yet.
"""
libhandyg_path() = _LIB_PATH[]
