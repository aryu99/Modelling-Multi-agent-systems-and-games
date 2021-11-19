# Struct for holding pertinent components of a quadratic cost function coupling
# two players' variables. Declared `mutable` so that other player's state can be
# updated between rounds of IBR.
export QuadraticDifferenceCost
mutable struct QuadraticDifferenceCost{
    T1 <: AbstractFloat,T2 <: Integer} <: CoupledCost
    weight::T1              # Cost scaling ≥ 0.
    dimension::T2           # Dimension in which to apply cost.
    other_player_idx::T2    # Index of player to whom this does *not* apply.
    x̃::Union{Nothing, AbstractMatrix{T1}} # Matrix of states for other player.
end

QuadraticDifferenceCost(w, dim, idx) = QuadraticDifferenceCost(
    w, dim, idx, nothing)

# Should return:
#           0.5 * weight * Σₜ(xₜ[dim] - x̃ₜ[dim])²
function evaluate(c::QuadraticDifferenceCost, x)
    # TODO!
    return 0.5 * c.weight * sum((x[c.dimension,:] - c.x̃[c.dimension, :]).^2)    
end
