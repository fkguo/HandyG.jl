const _LIB_PATH = Ref{String}("")
const _LIB_HANDLE = Ref{Ptr{Nothing}}(C_NULL)

@inline function _lib_filename()
    if Sys.iswindows()
        return "libhandyg.dll"
    elseif Sys.isapple()
        return "libhandyg.dylib"
    else
        return "libhandyg.so"
    end
end

function _find_libhandyg()
    if haskey(ENV, "HANDYG_LIB")
        return ENV["HANDYG_LIB"]
    end

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

    local_dev = normpath(joinpath(@__DIR__, "..", "deps", "usr", "lib", _lib_filename()))
    if isfile(local_dev)
        return local_dev
    end

    found = Libdl.find_library(["handyg", "libhandyg"], String[])
    if !isempty(found)
        return found
    end

    error("HandyG: libhandyg not found. Provide an artifact in `Artifacts.toml`, set ENV[\"HANDYG_LIB\"], or run `bash deps/build_local.sh` to build a dev copy into `deps/usr/lib`.")
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

libhandyg_path() = _LIB_PATH[]
