const I0_PLUS = Int8(+1)
const I0_MINUS = Int8(-1)
const I0_DEFAULT = I0_PLUS

struct INum{T<:Real}
    c::Complex{T}
    i0::Int8
end

struct INumVec{T<:Real, VC<:StridedVector{Complex{T}}, VI<:StridedVector{Int8}}
    c::VC
    i0::VI
end

struct INumMat{T<:Real, MC<:StridedMatrix{Complex{T}}, MI<:StridedMatrix{Int8}}
    c::MC
    i0::MI
end

inum(z::Complex{T}, i0::Integer=I0_DEFAULT) where {T<:Real} = INum{T}(z, Int8(i0))
inum(x::T, i0::Integer=I0_DEFAULT) where {T<:Real} = INum{T}(complex(x, zero(x)), Int8(i0))

function inum(c::StridedVector{Complex{T}}, i0::StridedVector{Int8}) where {T<:Real}
    length(c) == length(i0) || throw(ArgumentError("inum(c,i0): length mismatch"))
    return INumVec{T, typeof(c), typeof(i0)}(c, i0)
end

function inum(c::StridedMatrix{Complex{T}}, i0::StridedMatrix{Int8}) where {T<:Real}
    size(c) == size(i0) || throw(ArgumentError("inum(c,i0): size mismatch"))
    return INumMat{T, typeof(c), typeof(i0)}(c, i0)
end

