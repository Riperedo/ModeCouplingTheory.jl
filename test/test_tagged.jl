
F0 = 1.0
∂F0 = 0.0
α = 1.0
β = 0.0
γ = 1.0
λ1 = 2.0
λ2 = 1.0
kernel = ModeCouplingTheory.SchematicF2Kernel(λ1)
eq = LinearMCTEquation(α, β, γ, F0, ∂F0, kernel)
sol = solve(eq)

taggedkernel = ModeCouplingTheory.TaggedSchematicF2Kernel(λ2, sol)
tagged_eq = LinearMCTEquation(α, β, γ, F0, ∂F0, taggedkernel)
tagged_sol = solve(tagged_eq);

F0 = @SVector [1.0, 1.0]
∂F0 = @SVector [0.0, 0.0]
import ModeCouplingTheory.MemoryKernel
import ModeCouplingTheory.evaluate_kernel
struct SjogrenKernel <: MemoryKernel
    ν1::Float64
    ν2::Float64
end

function evaluate_kernel(kernel::SjogrenKernel, F, t)
    return Diagonal(@SVector [kernel.ν1*F[1]^2, kernel.ν2*F[1]*F[2]])
end

kernel = SjogrenKernel(λ1, λ2)
eq = LinearMCTEquation(α, β, γ, F0, ∂F0, kernel)
sol = solve(eq)
@test maximum(abs.(sol[2] .- tagged_sol[1])) < 10^-10
