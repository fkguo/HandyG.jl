const I0_PLUS = Int8(+1)
const I0_MINUS = Int8(-1)
const I0_DEFAULT = I0_PLUS

"""
    INum{T<:Real}

Scalar value with an explicit `i0±` prescription (upstream handyG `inum`).

Fields:
- `c::Complex{T}`: complex value
- `i0::Int8`: `+1` or `-1`

Construct with [`inum`](@ref).
"""
struct INum{T<:Real}
    c::Complex{T}
    i0::Int8
end

"""
    INumVec{T}

Structure-of-arrays (SoA) representation of a vector of `inum` values.

Fields:
- `c`: `StridedVector{Complex{T}}`
- `i0`: `StridedVector{Int8}`

Construct with [`inum`](@ref).
"""
struct INumVec{T<:Real, VC<:StridedVector{Complex{T}}, VI<:StridedVector{Int8}}
    c::VC
    i0::VI
end

"""
    INumMat{T}

Structure-of-arrays (SoA) representation of a matrix of `inum` values, intended for batch calls.

Fields:
- `c`: `StridedMatrix{Complex{T}}`
- `i0`: `StridedMatrix{Int8}`

Construct with [`inum`](@ref).
"""
struct INumMat{T<:Real, MC<:StridedMatrix{Complex{T}}, MI<:StridedMatrix{Int8}}
    c::MC
    i0::MI
end

"""
    inum(z::Complex{T}, i0::Integer=+1) where {T<:Real} -> INum{T}
    inum(x::T, i0::Integer=+1) where {T<:Real} -> INum{T}
    inum(c::StridedVector{Complex{T}}, i0::StridedVector{Int8}) where {T<:Real} -> INumVec{T}
    inum(c::StridedMatrix{Complex{T}}, i0::StridedMatrix{Int8}) where {T<:Real} -> INumMat{T}

Create `i0±`-aware inputs (upstream handyG `inum`).

`i0` should be `Int8(+1)` or `Int8(-1)`. For complex values with non-zero imaginary part,
upstream handyG treats the sign of `imag(z)` as the prescription regardless of `i0`.
"""
inum(z::Complex{T}, i0::Integer=I0_DEFAULT) where {T<:Real} = INum{T}(z, Int8(i0))
inum(x::T, i0::Integer=I0_DEFAULT) where {T<:Real} = INum{T}(complex(x, zero(x)), Int8(i0))

function inum(c::StridedVector{Complex{T}}, i0::StridedVector{Int8}) where {T<:Real}
    length(c) == length(i0) || throw(ArgumentError("inum(c,i0): length mismatch"))
    return INumVec{T, typeof(c), typeof(i0)}(c, i0)
end

"""
    inum(c::StridedVector{Complex{T}}, i0::AbstractVector{<:Integer}) where {T<:Real} -> INumVec{T}

Convenience overload accepting any integer element type for `i0`.

This allocates a temporary `Vector{Int8}`. For allocation-free hot paths, pass `i0::Vector{Int8}`.
"""
function inum(c::StridedVector{Complex{T}}, i0::AbstractVector{<:Integer}) where {T<:Real}
    length(c) == length(i0) || throw(ArgumentError("inum(c,i0): length mismatch"))
    i0c = Vector{Int8}(undef, length(i0))
    j = 1
    @inbounds for v in i0
        i0c[j] = Int8(v)
        j += 1
    end
    return inum(c, i0c)
end

function inum(c::StridedMatrix{Complex{T}}, i0::StridedMatrix{Int8}) where {T<:Real}
    size(c) == size(i0) || throw(ArgumentError("inum(c,i0): size mismatch"))
    return INumMat{T, typeof(c), typeof(i0)}(c, i0)
end

"""
    inum(c::StridedMatrix{Complex{T}}, i0::AbstractMatrix{<:Integer}) where {T<:Real} -> INumMat{T}

Convenience overload accepting any integer element type for `i0`.

This allocates a temporary `Matrix{Int8}`. For allocation-free hot paths, pass `i0::Matrix{Int8}`.
"""
function inum(c::StridedMatrix{Complex{T}}, i0::AbstractMatrix{<:Integer}) where {T<:Real}
    size(c) == size(i0) || throw(ArgumentError("inum(c,i0): size mismatch"))
    i0c = Matrix{Int8}(undef, size(i0))
    @inbounds for j in eachindex(i0)
        i0c[j] = Int8(i0[j])
    end
    return inum(c, i0c)
end
