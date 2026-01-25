"""
    clearcache!()
    clearcache()

Clear handyG's internal caches.

The upstream authors recommend calling this between phase-space points in Monte Carlo workloads.
"""
clearcache!() = _handyg_clearcache()
clearcache() = clearcache!()

"""
    set_mpldelta!(x::Float64)

Set the MPL truncation threshold (`MPLdel` in the upstream API).
"""
set_mpldelta!(x::Float64) = _handyg_set_mpldelta!(x)

"""
    set_lidelta!(x::Float64)

Set the polylog series truncation threshold (`Lidel` in the upstream API).
"""
set_lidelta!(x::Float64) = _handyg_set_lidelta!(x)

"""
    set_hoelder_circle!(x::Float64)

Set the H&ouml;lder circle size (`hCircle` in the upstream API).
"""
set_hoelder_circle!(x::Float64) = _handyg_set_hoelder_circle!(x)

"""
    set_options!(; mpldelta=nothing, lidelta=nothing, hoelder_circle=nothing)

Convenience wrapper to set multiple runtime options at once.
"""
function set_options!(; mpldelta::Union{Nothing,Float64}=nothing, lidelta::Union{Nothing,Float64}=nothing, hoelder_circle::Union{Nothing,Float64}=nothing)
    mpldelta === nothing || set_mpldelta!(mpldelta)
    lidelta === nothing || set_lidelta!(lidelta)
    hoelder_circle === nothing || set_hoelder_circle!(hoelder_circle)
    return nothing
end

const _SCRATCH_CINT_VEC = [Cint[] for _ in 1:max(1, Threads.nthreads())]

@inline function _collect_cint_vec(x::AbstractVector{<:Integer})
    n = length(x)
    y = _SCRATCH_CINT_VEC[Threads.threadid()]
    resize!(y, n)
    j = 1
    @inbounds for v in x
        y[j] = Cint(v)
        j += 1
    end
    return y
end

@inline function _collect_cint_mat(x::AbstractMatrix{<:Integer})
    y = Matrix{Cint}(undef, size(x))
    @inbounds for j in eachindex(x)
        y[j] = Cint(x[j])
    end
    return y
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

"""
    G(g::StridedVector{Float64}) -> ComplexF64
    G(g::StridedVector{ComplexF64}) -> ComplexF64
    G(z::StridedVector, y) -> ComplexF64
    G(m::StridedVector{Cint}, z::StridedVector, y) -> ComplexF64
    G(z::INumVec, y::INum) -> ComplexF64
    G(m::StridedVector{Cint}, z::INumVec, y::INum) -> ComplexF64

Evaluate a generalized polylogarithm using handyG.

Dispatch selects one of the upstream calling conventions:

- **superflat**: `G(g)` where `g = [z..., y]`
- **flat**: `G(z, y)`
- **condensed**: `G(m, z, y)`

For explicit `i0±` prescriptions, use [`inum`](@ref) inputs.
"""
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

"""
    G(m::AbstractVector{<:Integer}, z, y) -> ComplexF64

Convenience overload for condensed form that accepts any integer element type for `m`.

This method allocates a temporary `Vector{Cint}` for ABI compatibility. For allocation-free
hot paths, pass `m::Vector{Cint}`.
"""
@inline function G(m::AbstractVector{<:Integer}, z::StridedVector{Float64}, y::Union{Real,ComplexF64})
    return G(_collect_cint_vec(m), z, y)
end

@inline function G(m::AbstractVector{<:Integer}, z::StridedVector{ComplexF64}, y::Union{Real,ComplexF64})
    return G(_collect_cint_vec(m), z, y)
end

@inline function G(m::AbstractVector{<:Integer}, z::INumVec{Float64}, y::INum{Float64})
    return G(_collect_cint_vec(m), z, y)
end

"""
    G!(out::Ref{ComplexF64}, args...) -> out
    G!(out::StridedVector{ComplexF64}, args...) -> out

In-place evaluation.

- If `out` is a `Ref{ComplexF64}`, evaluates a single GPL and writes to `out[]`.
- If `out` is a vector, dispatches to [`G_batch!`](@ref) for batched evaluation.
"""
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

"""
    G!(out::Ref{ComplexF64}, m::AbstractVector{<:Integer}, z, y) -> out

Convenience overload for condensed form that accepts any integer element type for `m`.

This method allocates a temporary `Vector{Cint}` for ABI compatibility. For allocation-free
hot paths, pass `m::Vector{Cint}`.
"""
@inline function G!(out::Ref{ComplexF64}, m::AbstractVector{<:Integer}, z::StridedVector{Float64}, y::Union{Real,ComplexF64})
    return G!(out, _collect_cint_vec(m), z, y)
end

@inline function G!(out::Ref{ComplexF64}, m::AbstractVector{<:Integer}, z::StridedVector{ComplexF64}, y::Union{Real,ComplexF64})
    return G!(out, _collect_cint_vec(m), z, y)
end

@inline function G!(out::Ref{ComplexF64}, m::AbstractVector{<:Integer}, z::INumVec{Float64}, y::INum{Float64})
    return G!(out, _collect_cint_vec(m), z, y)
end

"""
    G_batch!(out, g, len) -> out
    G_batch!(out, z, y, len) -> out
    G_batch!(out, m, z, y, len) -> out

Batched evaluation for many independent GPL calls.

Batch inputs use fixed-depth column-major matrices `(depth_max, N)` and a `len::Vector{Cint}`
giving the active length of each column. Results are written to `out::Vector{ComplexF64}` of
length `N`.
"""
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

"""
    G_batch!(out, args..., len::AbstractVector{<:Integer}) -> out

Convenience overloads that accept any integer element type for `len` (and `m` in condensed form).

These methods allocate temporary `Vector{Cint}` / `Matrix{Cint}` buffers for ABI compatibility.
For allocation-free hot paths, pass `len::Vector{Cint}` and (if applicable) `m::Matrix{Cint}`.
"""
@inline function G_batch!(out::StridedVector{ComplexF64}, g::StridedMatrix{Float64}, len::AbstractVector{<:Integer})
    return G_batch!(out, g, _collect_cint_vec(len))
end

@inline function G_batch!(out::StridedVector{ComplexF64}, g::StridedMatrix{ComplexF64}, len::AbstractVector{<:Integer})
    return G_batch!(out, g, _collect_cint_vec(len))
end

@inline function G_batch!(out::StridedVector{ComplexF64}, z::StridedMatrix{Float64}, y::StridedVector{ComplexF64}, len::AbstractVector{<:Integer})
    return G_batch!(out, z, y, _collect_cint_vec(len))
end

@inline function G_batch!(out::StridedVector{ComplexF64}, z::StridedMatrix{ComplexF64}, y::StridedVector{ComplexF64}, len::AbstractVector{<:Integer})
    return G_batch!(out, z, y, _collect_cint_vec(len))
end

@inline function G_batch!(out::StridedVector{ComplexF64}, z::INumMat{Float64}, y::INumVec{Float64}, len::AbstractVector{<:Integer})
    return G_batch!(out, z, y, _collect_cint_vec(len))
end

@inline function G_batch!(out::StridedVector{ComplexF64}, m::AbstractMatrix{<:Integer}, z::StridedMatrix{Float64}, y::StridedVector{ComplexF64}, len::AbstractVector{<:Integer})
    return G_batch!(out, _collect_cint_mat(m), z, y, _collect_cint_vec(len))
end

@inline function G_batch!(out::StridedVector{ComplexF64}, m::AbstractMatrix{<:Integer}, z::StridedMatrix{ComplexF64}, y::StridedVector{ComplexF64}, len::AbstractVector{<:Integer})
    return G_batch!(out, _collect_cint_mat(m), z, y, _collect_cint_vec(len))
end

@inline function G_batch!(out::StridedVector{ComplexF64}, m::AbstractMatrix{<:Integer}, z::INumMat{Float64}, y::INumVec{Float64}, len::AbstractVector{<:Integer})
    return G_batch!(out, _collect_cint_mat(m), z, y, _collect_cint_vec(len))
end

@inline function G!(out::StridedVector{ComplexF64}, args...)
    return G_batch!(out, args...)
end
