clearcache!() = _handyg_clearcache()
clearcache() = clearcache!()

set_mpldelta!(x::Float64) = _handyg_set_mpldelta!(x)
set_lidelta!(x::Float64) = _handyg_set_lidelta!(x)
set_hoelder_circle!(x::Float64) = _handyg_set_hoelder_circle!(x)

function set_options!(; mpldelta::Union{Nothing,Float64}=nothing, lidelta::Union{Nothing,Float64}=nothing, hoelder_circle::Union{Nothing,Float64}=nothing)
    mpldelta === nothing || set_mpldelta!(mpldelta)
    lidelta === nothing || set_lidelta!(lidelta)
    hoelder_circle === nothing || set_hoelder_circle!(hoelder_circle)
    return nothing
end

@inline function _require_len_at_least!(len::StridedVector{Cint}, minlen::Integer)
    _check_strided_vector(len)
    @inbounds for j in eachindex(len)
        len[j] >= minlen || throw(ArgumentError("len[$j] must be >= $minlen"))
    end
    return nothing
end

@inline function _require_len_at_most!(len::StridedVector{Cint}, maxlen::Integer)
    _check_strided_vector(len)
    @inbounds for j in eachindex(len)
        len[j] <= maxlen || throw(ArgumentError("len[$j] must be <= depth_max=$maxlen"))
    end
    return nothing
end

@inline function G(g::StridedVector{Float64})
    length(g) >= 2 || throw(ArgumentError("superflat form requires length(g) >= 2 (last entry is y)"))
    out = _scratch_out()
    _g_superflat!(out, g)
    return out[]
end

@inline function G(g::StridedVector{ComplexF64})
    length(g) >= 2 || throw(ArgumentError("superflat form requires length(g) >= 2 (last entry is y)"))
    out = _scratch_out()
    _g_superflat!(out, g)
    return out[]
end

@inline function G(z::StridedVector{Float64}, y::Real)
    length(z) >= 1 || throw(ArgumentError("flat form requires length(z) >= 1"))
    out = _scratch_out()
    _g_flat!(out, z, complex(Float64(y), 0.0))
    return out[]
end

@inline function G(z::StridedVector{Float64}, y::ComplexF64)
    length(z) >= 1 || throw(ArgumentError("flat form requires length(z) >= 1"))
    out = _scratch_out()
    _g_flat!(out, z, y)
    return out[]
end

@inline function G(z::StridedVector{ComplexF64}, y::Real)
    length(z) >= 1 || throw(ArgumentError("flat form requires length(z) >= 1"))
    out = _scratch_out()
    _g_flat!(out, z, complex(Float64(y), 0.0))
    return out[]
end

@inline function G(z::StridedVector{ComplexF64}, y::ComplexF64)
    length(z) >= 1 || throw(ArgumentError("flat form requires length(z) >= 1"))
    out = _scratch_out()
    _g_flat!(out, z, y)
    return out[]
end

@inline function G(z::INumVec{Float64}, y::INum{Float64})
    length(z.c) >= 1 || throw(ArgumentError("flat form requires length(z) >= 1"))
    out = _scratch_out()
    _g_flat_i0!(out, z, y)
    return out[]
end

@inline function G(m::StridedVector{Cint}, z::StridedVector{Float64}, y::Union{Real,ComplexF64})
    length(z) >= 1 || throw(ArgumentError("condensed form requires length(z) >= 1"))
    length(m) == length(z) || throw(ArgumentError("condensed form requires length(m) == length(z)"))
    out = _scratch_out()
    _g_condensed!(out, m, z, ComplexF64(y))
    return out[]
end

@inline function G(m::StridedVector{Cint}, z::StridedVector{ComplexF64}, y::Union{Real,ComplexF64})
    length(z) >= 1 || throw(ArgumentError("condensed form requires length(z) >= 1"))
    length(m) == length(z) || throw(ArgumentError("condensed form requires length(m) == length(z)"))
    out = _scratch_out()
    _g_condensed!(out, m, z, ComplexF64(y))
    return out[]
end

@inline function G(m::StridedVector{Cint}, z::INumVec{Float64}, y::INum{Float64})
    length(z.c) >= 1 || throw(ArgumentError("condensed form requires length(z) >= 1"))
    length(m) == length(z.c) || throw(ArgumentError("condensed form requires length(m) == length(z)"))
    out = _scratch_out()
    _g_condensed_i0!(out, m, z, y)
    return out[]
end

@inline function G!(out::Ref{ComplexF64}, g::StridedVector{Float64})
    length(g) >= 2 || throw(ArgumentError("superflat form requires length(g) >= 2 (last entry is y)"))
    _g_superflat!(out, g)
    return out
end

@inline function G!(out::Ref{ComplexF64}, g::StridedVector{ComplexF64})
    length(g) >= 2 || throw(ArgumentError("superflat form requires length(g) >= 2 (last entry is y)"))
    _g_superflat!(out, g)
    return out
end

@inline function G!(out::Ref{ComplexF64}, z::StridedVector{Float64}, y::Union{Real,ComplexF64})
    length(z) >= 1 || throw(ArgumentError("flat form requires length(z) >= 1"))
    _g_flat!(out, z, ComplexF64(y))
    return out
end

@inline function G!(out::Ref{ComplexF64}, z::StridedVector{ComplexF64}, y::Union{Real,ComplexF64})
    length(z) >= 1 || throw(ArgumentError("flat form requires length(z) >= 1"))
    _g_flat!(out, z, ComplexF64(y))
    return out
end

@inline function G!(out::Ref{ComplexF64}, z::INumVec{Float64}, y::INum{Float64})
    length(z.c) >= 1 || throw(ArgumentError("flat form requires length(z) >= 1"))
    _g_flat_i0!(out, z, y)
    return out
end

@inline function G!(out::Ref{ComplexF64}, m::StridedVector{Cint}, z::StridedVector{Float64}, y::Union{Real,ComplexF64})
    length(z) >= 1 || throw(ArgumentError("condensed form requires length(z) >= 1"))
    length(m) == length(z) || throw(ArgumentError("condensed form requires length(m) == length(z)"))
    _g_condensed!(out, m, z, ComplexF64(y))
    return out
end

@inline function G!(out::Ref{ComplexF64}, m::StridedVector{Cint}, z::StridedVector{ComplexF64}, y::Union{Real,ComplexF64})
    length(z) >= 1 || throw(ArgumentError("condensed form requires length(z) >= 1"))
    length(m) == length(z) || throw(ArgumentError("condensed form requires length(m) == length(z)"))
    _g_condensed!(out, m, z, ComplexF64(y))
    return out
end

@inline function G!(out::Ref{ComplexF64}, m::StridedVector{Cint}, z::INumVec{Float64}, y::INum{Float64})
    length(z.c) >= 1 || throw(ArgumentError("condensed form requires length(z) >= 1"))
    length(m) == length(z.c) || throw(ArgumentError("condensed form requires length(m) == length(z)"))
    _g_condensed_i0!(out, m, z, y)
    return out
end

@inline function G_batch!(out::StridedVector{ComplexF64}, g::StridedMatrix{Float64}, len::StridedVector{Cint})
    size(g, 2) == length(out) || throw(ArgumentError("out length must match number of columns"))
    size(g, 2) == length(len) || throw(ArgumentError("len length must match number of columns"))
    _require_len_at_least!(len, 2)
    _require_len_at_most!(len, size(g, 1))
    return _g_superflat_batch!(out, g, len)
end

@inline function G_batch!(out::StridedVector{ComplexF64}, g::StridedMatrix{ComplexF64}, len::StridedVector{Cint})
    size(g, 2) == length(out) || throw(ArgumentError("out length must match number of columns"))
    size(g, 2) == length(len) || throw(ArgumentError("len length must match number of columns"))
    _require_len_at_least!(len, 2)
    _require_len_at_most!(len, size(g, 1))
    return _g_superflat_batch!(out, g, len)
end

@inline function G_batch!(out::StridedVector{ComplexF64}, z::StridedMatrix{Float64}, y::StridedVector{ComplexF64}, len::StridedVector{Cint})
    size(z, 2) == length(out) || throw(ArgumentError("out length must match number of columns"))
    size(z, 2) == length(y) || throw(ArgumentError("y length must match number of columns"))
    size(z, 2) == length(len) || throw(ArgumentError("len length must match number of columns"))
    _require_len_at_least!(len, 1)
    _require_len_at_most!(len, size(z, 1))
    return _g_flat_batch!(out, z, y, len)
end

@inline function G_batch!(out::StridedVector{ComplexF64}, z::StridedMatrix{ComplexF64}, y::StridedVector{ComplexF64}, len::StridedVector{Cint})
    size(z, 2) == length(out) || throw(ArgumentError("out length must match number of columns"))
    size(z, 2) == length(y) || throw(ArgumentError("y length must match number of columns"))
    size(z, 2) == length(len) || throw(ArgumentError("len length must match number of columns"))
    _require_len_at_least!(len, 1)
    _require_len_at_most!(len, size(z, 1))
    return _g_flat_batch!(out, z, y, len)
end

@inline function G_batch!(out::StridedVector{ComplexF64}, z::INumMat{Float64}, y::INumVec{Float64}, len::StridedVector{Cint})
    size(z.c, 2) == length(out) || throw(ArgumentError("out length must match number of columns"))
    size(z.c, 2) == length(y.c) || throw(ArgumentError("y length must match number of columns"))
    size(z.c, 2) == length(len) || throw(ArgumentError("len length must match number of columns"))
    _require_len_at_least!(len, 1)
    _require_len_at_most!(len, size(z.c, 1))
    return _g_flat_batch_i0!(out, z, y, len)
end

@inline function G_batch!(out::StridedVector{ComplexF64}, m::StridedMatrix{Cint}, z::StridedMatrix{Float64}, y::StridedVector{ComplexF64}, len::StridedVector{Cint})
    size(z, 2) == length(out) || throw(ArgumentError("out length must match number of columns"))
    size(z, 2) == length(y) || throw(ArgumentError("y length must match number of columns"))
    size(z, 2) == length(len) || throw(ArgumentError("len length must match number of columns"))
    size(z) == size(m) || throw(ArgumentError("m and z must have same size"))
    _require_len_at_least!(len, 1)
    _require_len_at_most!(len, size(z, 1))
    return _g_condensed_batch!(out, m, z, y, len)
end

@inline function G_batch!(out::StridedVector{ComplexF64}, m::StridedMatrix{Cint}, z::StridedMatrix{ComplexF64}, y::StridedVector{ComplexF64}, len::StridedVector{Cint})
    size(z, 2) == length(out) || throw(ArgumentError("out length must match number of columns"))
    size(z, 2) == length(y) || throw(ArgumentError("y length must match number of columns"))
    size(z, 2) == length(len) || throw(ArgumentError("len length must match number of columns"))
    size(z) == size(m) || throw(ArgumentError("m and z must have same size"))
    _require_len_at_least!(len, 1)
    _require_len_at_most!(len, size(z, 1))
    return _g_condensed_batch!(out, m, z, y, len)
end

@inline function G_batch!(out::StridedVector{ComplexF64}, m::StridedMatrix{Cint}, z::INumMat{Float64}, y::INumVec{Float64}, len::StridedVector{Cint})
    size(z.c, 2) == length(out) || throw(ArgumentError("out length must match number of columns"))
    size(z.c, 2) == length(y.c) || throw(ArgumentError("y length must match number of columns"))
    size(z.c, 2) == length(len) || throw(ArgumentError("len length must match number of columns"))
    size(z.c) == size(m) || throw(ArgumentError("m and z must have same size"))
    _require_len_at_least!(len, 1)
    _require_len_at_most!(len, size(z.c, 1))
    return _g_condensed_batch_i0!(out, m, z, y, len)
end

@inline function G!(out::StridedVector{ComplexF64}, args...)
    return G_batch!(out, args...)
end
