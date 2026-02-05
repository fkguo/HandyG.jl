const _LIB_PATH = Ref{String}("")

function __init__()
    _LIB_PATH[] = HandyG_jll.libhandyg
    return nothing
end

@inline function _ensure_libhandyg!()
    isempty(_LIB_PATH[]) && __init__()
    return _LIB_PATH[]
end

"""
    libhandyg_path() -> String

Return the filesystem path of the `libhandyg` shared library (provided by `HandyG_jll`).
"""
libhandyg_path() = _LIB_PATH[]
