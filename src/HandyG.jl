module HandyG

export INum, inum

struct INum{T<:Real}
    c::Complex{T}
    i0::Int8
end

const I0_PLUS = Int8(+1)
const I0_MINUS = Int8(-1)
const I0_DEFAULT = I0_PLUS

inum(z::Complex{T}, i0::Integer=I0_DEFAULT) where {T<:Real} = INum{T}(z, Int8(i0))
inum(x::Real, i0::Integer=I0_DEFAULT) = INum{typeof(x)}(complex(x, zero(x)), Int8(i0))

end # module HandyG

