#
#      Rn - The manifold of the n-dimensional (real valued) Euclidean space
#
# Manopt.jl, R. Bergmann, 2018-06-26
import LinearAlgebra: I, norm
import Base: exp, log, show
export Euclidean, RnPoint, RnTVector
export distance, exp, log, norm, dot, manifoldDimension, show, getValue
export zeroTVector, tangentONB, randomMPoint, randomTVector
export validateMPoint, validateTVector, typeofMPoint, typeofTVector
# Types
# ---

@doc doc"""
    Euclidean <: Manifold
The manifold $\mathcal M = \mathbb R^n$ of the $n$-dimensional Euclidean vector
space. We employ the notation $\langle\cdot,\cdot,\rangle$ for the inner product
and $\lVert\cdot\rVert_2$ for its induced norm.
The abbreviation for functions is `Rn`
"""
struct Euclidean <: Manifold
  name::String
  dimension::Int
  abbreviation::String
  Euclidean(dimension::Int) = new("$dimension-dimensional Euclidean space",dimension,"R$dimension")
end

@doc doc"""
    RnPoint <: MPoint
The point $x\in\mathbb M$ for $\mathbb M=\mathbb R^n$ represented by an
$n$-dimensional `Vector{T}`, where `T <: AbstractFloat`.
"""
struct RnPoint{T<:AbstractFloat} <: MPoint
  value::Vector{T}
  RnPoint{T}( value::Vector{T} ) where T<:AbstractFloat = new(value)
  RnPoint{T}( value::T ) where T<:AbstractFloat = new([value])
end
RnPoint(value::T) where {T <: AbstractFloat} = RnPoint{T}(value)
RnPoint(value::Vector{T}) where {T <: AbstractFloat} = RnPoint{T}(value)
getValue(x::RnPoint) = length(x.value)==1 ? x.value[1] : x.value

@doc doc"""
    RnTVector <: TVector
The point $\xi\in\mathbb M$ for $\mathbb M=\mathbb R^n$ represented by an
$n$-dimensional `Vector{T}`, where `T <: AbstractFloat`.
"""
struct RnTVector{T <: AbstractFloat}  <: TVector
  value::Vector{T}
  RnTVector{T}(value::Vector{T})  where {T <: AbstractFloat}  = new(value)
  RnTVector{T}(value::T) where {T <: AbstractFloat}  = new([value])
end
RnTVector(value::T) where {T <: AbstractFloat} = RnTVector{T}(value)
RnTVector(value::Vector{T})  where {T <: AbstractFloat}  = RnTVector{T}(value)

getValue(ξ::RnTVector) = length(ξ.value)==1 ? ξ.value[1] : ξ.value

# Traits
# ---
# (a) Rn is a MatrixManifold
@traitimpl IsMatrixM{Euclidean}
@traitimpl IsMatrixP{RnPoint}
@traitimpl IsMatrixV{RnTVector}

# Functions
# ---
@doc doc"""
    distance(M,x,y)
Computes the Euclidean distance $\lVert x - y\rVert$
"""
function distance(M::Euclidean,x::RnPoint{T},y::RnPoint{T})::T where {T <: AbstractFloat}
    if length(getValue(x)) > 1
        return norm( getValue(x) - getValue(y) )
    else
        return abs( getValue(x) - getValue(y) )
    end
end
@doc doc"""
    dot(M,x,ξ,ν)
Computes the Euclidean inner product of `ξ` and `ν`, i.e.
$\langle\xi,\nu\rangle = \displaystyle\sum_{k=1}^n \xi_k\nu_k$.
"""
dot(M::Euclidean,x::RnPoint{T},ξ::RnTVector{T}, ν::RnTVector{T}) where {T <: AbstractFloat} = dot( getValue(ξ) , getValue(ν) )
@doc doc"""
    exp(M,x,ξ[, t=1.0])
Computes the exponential map, i.e. $x+t*\xi$, where the scaling parameter `t` is
optional.
"""
exp(M::Euclidean,x::RnPoint{T},ξ::RnTVector{T},t::Number=1.0) where {T <: AbstractFloat} = RnPoint(getValue(x) + t*getValue(ξ) )
@doc doc"""
    log(M,x,y)
Computes the logarithmic map, i.e. $y-x$.
"""
log(M::Euclidean,x::RnPoint{T},y::RnPoint{T})  where {T <: AbstractFloat} = RnTVector( getValue(y) - getValue(x) )
"""
    manifoldDimension(x)
Returns the manifold dimension, i.e. the length of the vector `x`.
"""
manifoldDimension(x::RnPoint) = length( getValue(x) )
"""
    manifoldDimension(M)
Returns the manifold dimension, i.e. the length of the vectors stored
in `M.dimension`.
"""
manifoldDimension(M::Euclidean) = M.dimension
@doc doc"""
    norm(M,x,ξ)
Computes the length of the tangent vector `ξ` in the tangent
space $T_x\mathcal M$ of `x` on the Eclidean space `M`, i.e. $\lVert\xi\rVert$.
"""
norm(M::Euclidean,x::RnPoint{T}, ξ::RnTVector{T}) where {T <: AbstractFloat} = length(getValue(ξ)) == 1 ? abs( getValue(ξ) ) : norm( getValue(ξ) )
"""
    parallelTransport(M,x,y,ξ)
Computes the parallel transport, which is on [`Euclidean`](@ref) space the identity.
"""
parallelTransport(M::Euclidean, x::RnPoint{T}, y::RnPoint{T}, ξ::RnTVector{T})  where {T <: AbstractFloat} = ξ
doc"""
    randomMPoint(M[,T=Float64])

generate a random point on the [`Euclidean`](@ref), where the optional parameter
determines the type of the entries of the resulting [`RnPoint`](@ref).
"""
randomMPoint(M::Euclidean, T::DataType=Float64) = RnPoint( randn(T,M.dimension) )

doc"""
    randomTVector(M,x,:Gaussian[,σ=1.0])

generate a Gaussian random vector on the [`Euclidean`](@ref) manifold `M` with
standard deviation `σ`.
"""
randomTVector(M::Euclidean, x::RnPoint{T}, ::Val{:Gaussian}, σ::Real=1.0) where {T} = RnTVector( σ * randn(T,M.dimension) )

@doc doc"""
    (Ξ,κ) = tangentONB(M,x,y)
compute an ONB within the tangent space $T_x\mathcal M$ such that $\xi=\log_xy$ is the
first vector and compute the eigenvalues of the curvature tensor
$R(\Xi,\dot g)\dot g$, where $g=g_{x,\xi}$ is the geodesic with $g(0)=x$,
$\dot g(0) = \xi$, i.e. $\kappa_1$ corresponding to $\Xi_1=\xi$ is zero.

*See also:* [`jacobiField`](@ref), [`adjointJacobiField`](@ref).
"""
tangentONB(M::Euclidean, x::RnPoint{T}, y::RnPoint{T}) where {T <: AbstractFloat}  = tangentONB(M,x,log(M,x,y))
tangentONB(M::Euclidean, x::RnPoint{T}, ξ::RnTVector{T}) where {T <: AbstractFloat}  =
  [ RnTVector( Matrix{T}(I,manifoldDimension(x),manifoldDimension(x))[:,i] )
    for i in 1:manifoldDimension(x)], zeros(manifoldDimension(x))

typeofTVector(::Type{RnPoint{T}}) where T = RnTVector{T}
typeofMPoint(::Type{RnTVector{T}}) where T = RnPoint{T} 
                        
@doc doc"""
    typicalDistance(M)
returns the typical distance on the [`Euclidean`](@ref)` Rn`: $\sqrt(n)$.
"""
typicalDistance(M::Euclidean) = sqrt(M.dimension)

@doc doc"""
    validateMPoint(M,x)

Checks that a [`RnPoint`](@ref) `x` has a valid value for a point on the
[`Euclidean`](@ref) `M`$=\mathbb R1n$, which is the case if the dimensions fit. 
"""
validateMPoint(M::Euclidean, x::RnPoint) = manifoldDimension(M) == manifoldDimension(x)

@doc doc"""
    validateTVector(M,x,ξ)

Checks, that the [`RnTVector`](@ref) `ξ` is a valid tangent vector in the
tangent space of the [`RnPoint`](@ref) `x` ont the [`Euclidean`](@ref) `M`$=\mathbb R^n$,
which is always the case as long as the vector dimensions are the same.
""" 
validateTVector(M::Euclidean,x::RnPoint,ξ::RnTVector) = length(getValue(x) )== length(getValue(ξ))

@doc doc"""
    ξ = zeroTVector(M,x)

returns a zero vector in the tangent space $T_x\mathcal M$ of the
[`RnPoint`](@ref) $x\in\mathbb R^n$ on the [`Euclidean`](@ref)` Rn`.
"""
function zeroTVector(M::Euclidean, x::RnPoint{T}) where {T <: AbstractFloat}
    return RnTVector(  zero( getValue(x) )  )
end
#
#
# --- Display functions for the objects/types
show(io::IO, M::Euclidean) = print(io, "The $(M.name).");
show(io::IO, x::RnPoint) = print(io, "Rn($( getValue(x) ))");
show(io::IO, ξ::RnTVector) = print(io, "RnT($( getValue(ξ) ))");
