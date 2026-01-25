@inline function _check_strided_vector(x::StridedVector)
    stride(x, 1) == 1 || throw(ArgumentError("expected stride-1 StridedVector"))
    return nothing
end

@inline function _check_colmajor_matrix(x::StridedMatrix)
    stride(x, 1) == 1 || throw(ArgumentError("expected stride(x,1)=1 StridedMatrix"))
    stride(x, 2) == size(x, 1) || throw(ArgumentError("expected contiguous column-major matrix (stride(x,2)=size(x,1))"))
    return nothing
end

const _SCRATCH_OUT_COMPLEX_F64 = [Ref{ComplexF64}() for _ in 1:max(1, Threads.nthreads())]
const _SCRATCH_Y_COMPLEX_F64 = [Ref{ComplexF64}() for _ in 1:max(1, Threads.nthreads())]

@inline _scratch_out() = _SCRATCH_OUT_COMPLEX_F64[Threads.threadid()]

@inline function _scratch_y(y::ComplexF64)
    r = _SCRATCH_Y_COMPLEX_F64[Threads.threadid()]
    r[] = y
    return r
end

@inline function _g_superflat!(out::Ref{ComplexF64}, g::StridedVector{Float64})
    _ensure_libhandyg!()
    _check_strided_vector(g)
    ccall((:handyg_g_superflat_r, _LIB_PATH[]), Cvoid, (Ref{ComplexF64}, Ptr{Float64}, Cint), out, g, Cint(length(g)))
    return nothing
end

@inline function _g_superflat!(out::Ref{ComplexF64}, g::StridedVector{ComplexF64})
    _ensure_libhandyg!()
    _check_strided_vector(g)
    ccall((:handyg_g_superflat_c, _LIB_PATH[]), Cvoid, (Ref{ComplexF64}, Ptr{ComplexF64}, Cint), out, g, Cint(length(g)))
    return nothing
end

@inline function _g_flat!(out::Ref{ComplexF64}, z::StridedVector{Float64}, y::ComplexF64)
    _ensure_libhandyg!()
    _check_strided_vector(z)
    yref = _scratch_y(y)
    ccall((:handyg_g_flat_rc, _LIB_PATH[]), Cvoid, (Ref{ComplexF64}, Ptr{Float64}, Cint, Ref{ComplexF64}), out, z, Cint(length(z)), yref)
    return nothing
end

@inline function _g_flat!(out::Ref{ComplexF64}, z::StridedVector{ComplexF64}, y::ComplexF64)
    _ensure_libhandyg!()
    _check_strided_vector(z)
    yref = _scratch_y(y)
    ccall((:handyg_g_flat_cc, _LIB_PATH[]), Cvoid, (Ref{ComplexF64}, Ptr{ComplexF64}, Cint, Ref{ComplexF64}), out, z, Cint(length(z)), yref)
    return nothing
end

@inline function _g_flat_i0!(out::Ref{ComplexF64}, z::INumVec{Float64}, y::INum{Float64})
    _ensure_libhandyg!()
    _check_strided_vector(z.c)
    _check_strided_vector(z.i0)
    yref = _scratch_y(y.c)
    ccall((:handyg_g_flat_i0, _LIB_PATH[]), Cvoid, (Ref{ComplexF64}, Ptr{ComplexF64}, Ptr{Int8}, Cint, Ref{ComplexF64}, Int8), out, z.c, z.i0, Cint(length(z.c)), yref, y.i0)
    return nothing
end

@inline function _g_condensed!(out::Ref{ComplexF64}, m::StridedVector{Cint}, z::StridedVector{Float64}, y::ComplexF64)
    _ensure_libhandyg!()
    _check_strided_vector(m)
    _check_strided_vector(z)
    length(m) == length(z) || throw(ArgumentError("m and z must have the same length"))
    yref = _scratch_y(y)
    ccall((:handyg_g_condensed_rc, _LIB_PATH[]), Cvoid, (Ref{ComplexF64}, Ptr{Cint}, Ptr{Float64}, Cint, Ref{ComplexF64}), out, m, z, Cint(length(z)), yref)
    return nothing
end

@inline function _g_condensed!(out::Ref{ComplexF64}, m::StridedVector{Cint}, z::StridedVector{ComplexF64}, y::ComplexF64)
    _ensure_libhandyg!()
    _check_strided_vector(m)
    _check_strided_vector(z)
    length(m) == length(z) || throw(ArgumentError("m and z must have the same length"))
    yref = _scratch_y(y)
    ccall((:handyg_g_condensed_cc, _LIB_PATH[]), Cvoid, (Ref{ComplexF64}, Ptr{Cint}, Ptr{ComplexF64}, Cint, Ref{ComplexF64}), out, m, z, Cint(length(z)), yref)
    return nothing
end

@inline function _g_condensed_i0!(out::Ref{ComplexF64}, m::StridedVector{Cint}, z::INumVec{Float64}, y::INum{Float64})
    _ensure_libhandyg!()
    _check_strided_vector(m)
    _check_strided_vector(z.c)
    _check_strided_vector(z.i0)
    length(m) == length(z.c) || throw(ArgumentError("m and z must have the same length"))
    yref = _scratch_y(y.c)
    ccall((:handyg_g_condensed_i0, _LIB_PATH[]), Cvoid, (Ref{ComplexF64}, Ptr{Cint}, Ptr{ComplexF64}, Ptr{Int8}, Cint, Ref{ComplexF64}, Int8), out, m, z.c, z.i0, Cint(length(z.c)), yref, y.i0)
    return nothing
end

@inline function _g_superflat_batch!(out::StridedVector{ComplexF64}, g::StridedMatrix{Float64}, len::StridedVector{Cint})
    _ensure_libhandyg!()
    _check_strided_vector(out)
    _check_colmajor_matrix(g)
    _check_strided_vector(len)
    ccall((:handyg_g_superflat_batch_r, _LIB_PATH[]), Cvoid, (Ptr{ComplexF64}, Ptr{Float64}, Cint, Cint, Ptr{Cint}), out, g, Cint(size(g, 1)), Cint(size(g, 2)), len)
    return out
end

@inline function _g_superflat_batch!(out::StridedVector{ComplexF64}, g::StridedMatrix{ComplexF64}, len::StridedVector{Cint})
    _ensure_libhandyg!()
    _check_strided_vector(out)
    _check_colmajor_matrix(g)
    _check_strided_vector(len)
    ccall((:handyg_g_superflat_batch_c, _LIB_PATH[]), Cvoid, (Ptr{ComplexF64}, Ptr{ComplexF64}, Cint, Cint, Ptr{Cint}), out, g, Cint(size(g, 1)), Cint(size(g, 2)), len)
    return out
end

@inline function _g_flat_batch!(out::StridedVector{ComplexF64}, z::StridedMatrix{Float64}, y::StridedVector{ComplexF64}, len::StridedVector{Cint})
    _ensure_libhandyg!()
    _check_strided_vector(out)
    _check_colmajor_matrix(z)
    _check_strided_vector(y)
    _check_strided_vector(len)
    ccall((:handyg_g_flat_batch_rc, _LIB_PATH[]), Cvoid, (Ptr{ComplexF64}, Ptr{Float64}, Cint, Cint, Ptr{Cint}, Ptr{ComplexF64}), out, z, Cint(size(z, 1)), Cint(size(z, 2)), len, y)
    return out
end

@inline function _g_flat_batch!(out::StridedVector{ComplexF64}, z::StridedMatrix{ComplexF64}, y::StridedVector{ComplexF64}, len::StridedVector{Cint})
    _ensure_libhandyg!()
    _check_strided_vector(out)
    _check_colmajor_matrix(z)
    _check_strided_vector(y)
    _check_strided_vector(len)
    ccall((:handyg_g_flat_batch_cc, _LIB_PATH[]), Cvoid, (Ptr{ComplexF64}, Ptr{ComplexF64}, Cint, Cint, Ptr{Cint}, Ptr{ComplexF64}), out, z, Cint(size(z, 1)), Cint(size(z, 2)), len, y)
    return out
end

@inline function _g_flat_batch_i0!(out::StridedVector{ComplexF64}, z::INumMat{Float64}, y::INumVec{Float64}, len::StridedVector{Cint})
    _ensure_libhandyg!()
    _check_strided_vector(out)
    _check_colmajor_matrix(z.c)
    _check_colmajor_matrix(z.i0)
    _check_strided_vector(y.c)
    _check_strided_vector(y.i0)
    _check_strided_vector(len)
    ccall((:handyg_g_flat_batch_i0, _LIB_PATH[]), Cvoid, (Ptr{ComplexF64}, Ptr{ComplexF64}, Ptr{Int8}, Cint, Cint, Ptr{Cint}, Ptr{ComplexF64}, Ptr{Int8}), out, z.c, z.i0, Cint(size(z.c, 1)), Cint(size(z.c, 2)), len, y.c, y.i0)
    return out
end

@inline function _g_condensed_batch!(out::StridedVector{ComplexF64}, m::StridedMatrix{Cint}, z::StridedMatrix{Float64}, y::StridedVector{ComplexF64}, len::StridedVector{Cint})
    _ensure_libhandyg!()
    _check_strided_vector(out)
    _check_colmajor_matrix(m)
    _check_colmajor_matrix(z)
    _check_strided_vector(y)
    _check_strided_vector(len)
    ccall((:handyg_g_condensed_batch_rc, _LIB_PATH[]), Cvoid, (Ptr{ComplexF64}, Ptr{Cint}, Ptr{Float64}, Cint, Cint, Ptr{Cint}, Ptr{ComplexF64}), out, m, z, Cint(size(z, 1)), Cint(size(z, 2)), len, y)
    return out
end

@inline function _g_condensed_batch!(out::StridedVector{ComplexF64}, m::StridedMatrix{Cint}, z::StridedMatrix{ComplexF64}, y::StridedVector{ComplexF64}, len::StridedVector{Cint})
    _ensure_libhandyg!()
    _check_strided_vector(out)
    _check_colmajor_matrix(m)
    _check_colmajor_matrix(z)
    _check_strided_vector(y)
    _check_strided_vector(len)
    ccall((:handyg_g_condensed_batch_cc, _LIB_PATH[]), Cvoid, (Ptr{ComplexF64}, Ptr{Cint}, Ptr{ComplexF64}, Cint, Cint, Ptr{Cint}, Ptr{ComplexF64}), out, m, z, Cint(size(z, 1)), Cint(size(z, 2)), len, y)
    return out
end

@inline function _g_condensed_batch_i0!(out::StridedVector{ComplexF64}, m::StridedMatrix{Cint}, z::INumMat{Float64}, y::INumVec{Float64}, len::StridedVector{Cint})
    _ensure_libhandyg!()
    _check_strided_vector(out)
    _check_colmajor_matrix(m)
    _check_colmajor_matrix(z.c)
    _check_colmajor_matrix(z.i0)
    _check_strided_vector(y.c)
    _check_strided_vector(y.i0)
    _check_strided_vector(len)
    ccall((:handyg_g_condensed_batch_i0, _LIB_PATH[]), Cvoid, (Ptr{ComplexF64}, Ptr{Cint}, Ptr{ComplexF64}, Ptr{Int8}, Cint, Cint, Ptr{Cint}, Ptr{ComplexF64}, Ptr{Int8}), out, m, z.c, z.i0, Cint(size(z.c, 1)), Cint(size(z.c, 2)), len, y.c, y.i0)
    return out
end

@inline function _handyg_clearcache()
    _ensure_libhandyg!()
    ccall((:handyg_clearcache, _LIB_PATH[]), Cvoid, ())
    return nothing
end

@inline function _handyg_set_mpldelta!(x::Float64)
    _ensure_libhandyg!()
    xref = Ref{Float64}(x)
    ccall((:handyg_set_mpldelta, _LIB_PATH[]), Cvoid, (Ref{Float64},), xref)
    return nothing
end

@inline function _handyg_set_lidelta!(x::Float64)
    _ensure_libhandyg!()
    xref = Ref{Float64}(x)
    ccall((:handyg_set_lidelta, _LIB_PATH[]), Cvoid, (Ref{Float64},), xref)
    return nothing
end

@inline function _handyg_set_hoelder_circle!(x::Float64)
    _ensure_libhandyg!()
    xref = Ref{Float64}(x)
    ccall((:handyg_set_hoelder_circle, _LIB_PATH[]), Cvoid, (Ref{Float64},), xref)
    return nothing
end
