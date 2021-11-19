# Struct for holding pertinent components of a quadratic cost function.
export QuadraticCost
struct QuadraticCost{T1 <: AbstractFloat, T2 <: Integer} <: Cost
    weight::T1    # Cost scaling ≥ 0.
    nominal::T1   # Nominal value.
    dimension::T2 # Dimension in which to apply cost.
end

# Should return:
#           0.5 * weight * Σₜ(xₜ[dim] - nominal)²
function evaluate(c::QuadraticCost, x)
    # TODO!
    return 0.5 * c.weight * sum((x[c.dimension,:] .- c.nominal).^2)
end