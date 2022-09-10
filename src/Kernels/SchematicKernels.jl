"""
    ExponentiallyDecayingKernel{T<:Number} <: MemoryKernel

Scalar kernel with fields `ν` and `τ` which when called returns `ν exp(-t/τ)`.
"""
struct ExponentiallyDecayingKernel{T1<:Number, T2<:Number} <: MemoryKernel
    ν::T1
    τ::T2
end

function evaluate_kernel(kernel::ExponentiallyDecayingKernel, F::Number, t)
    return kernel.ν * exp(-t/kernel.τ)
end


"""
    SchematicF1Kernel{T<:Number} <: MemoryKernel

Scalar kernel with field `ν` which when called returns `ν F`.
"""
struct SchematicF1Kernel{T<:Number} <: MemoryKernel
    ν::T
end

function evaluate_kernel(kernel::SchematicF1Kernel, F::Number, t)
    ν = kernel.ν
    return ν * F
end

"""
    SchematicF2Kernel{T<:Number} <: MemoryKernel

Scalar kernel with field `ν` which when called returns `ν F^2`.
"""
struct SchematicF2Kernel{T<:Number} <: MemoryKernel
    ν::T
end

function evaluate_kernel(kernel::SchematicF2Kernel, F::Number, t)
    ν = kernel.ν
    return ν * F^2
end

"""
    SchematicF1Kernel{T<:Number} <: MemoryKernel

Scalar kernel with fields `ν1`, `ν2`, and `ν3` which when called returns `ν1 * F^1 + ν2 * F^2 + ν3 * F^3`.
"""
struct SchematicF123Kernel{T<:Number} <: MemoryKernel
    ν1::T
    ν2::T
    ν3::T
end

function evaluate_kernel(kernel::SchematicF123Kernel, F::Number, t)
    return kernel.ν1 * F^1 + kernel.ν2 * F^2 + kernel.ν3 * F^3
end


"""
    SchematicDiagonalKernel{T<:Union{SVector, Vector}} <: MemoryKernel

Matrix kernel with field `ν` which when called returns `Diagonal(ν .* F .^ 2)`, i.e., it implements a non-coupled system of SchematicF2Kernels.
"""
struct SchematicDiagonalKernel{T<:Union{SVector, Vector}} <: MemoryKernel
    ν::T
    SchematicDiagonalKernel(ν::T) where {T<:Union{SVector,Vector}} = eltype(ν) <: Number ? new{T}(ν) : error("element type of this kernel must be a number")
end

function evaluate_kernel(kernel::SchematicDiagonalKernel, F::Union{SVector,Vector}, t)
    ν = kernel.ν
    return Diagonal(ν .* F .^ 2)
end

function evaluate_kernel!(out::Diagonal, kernel::SchematicDiagonalKernel, F::Vector, t)
    ν = kernel.ν
    diag = out.diag
    @. diag = ν * F^2
end

"""
    SchematicMatrixKernel{T<:Union{SVector, Vector}} <: MemoryKernel

Matrix kernel with field `ν` which when called returns `ν * F * Fᵀ`, i.e., it implements Kαβ = ν*Fα*Fβ.
"""
struct SchematicMatrixKernel{T<:Union{SMatrix,Matrix}} <: MemoryKernel
    ν::T
    SchematicMatrixKernel(ν::T) where {T<:Union{SMatrix,Matrix}} = eltype(ν) <: Number ? new{T}(ν) : error("element type of this kernel must be a number")
end

function evaluate_kernel(kernel::SchematicMatrixKernel, F::Union{SVector,Vector}, t)
    ν = kernel.ν
    return ν * F * F'
end

function evaluate_kernel!(out::Matrix, kernel::SchematicMatrixKernel, F::Vector, t)
    ν = kernel.ν
    @tullio out[i, j] = ν[i, k] * F[k] * F[j]
end