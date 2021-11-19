using JuMP: @constraint

# Struct for holding pertinent information for constraining proximity
# between two agents. Declared `mutable` so that other player's state can be
# updated between rounds of IBR.
export CoupledProximityConstraint
mutable struct CoupledProximityConstraint{T1 <: Real,T2 <: Integer} <: CoupledConstraint
    δ::T1                # Minimum proximity.
    other_player_idx::T2 # Index of other player whom "ego" player is avoiding.
    pxdim::T2            # Horizontal and vertical position dims in state `x`.
    pydim::T2
    x̃::Union{Nothing, AbstractMatrix{T1}} # Matrix of states for other player.
end

CoupledProximityConstraint(δ, idx, pxdim, pydim) = CoupledProximityConstraint(
    δ, idx, pxdim, pydim, nothing)

# Enforces that: ||(x, y) - (x̃, ỹ)||² ≥ δ².
# NOTE: recall that `x` (and x̃) is indexed `x[:, time]`
function add_constraints!(c::CoupledProximityConstraint, model, x)
    # TODO!
    T = size(x, 2)
    @constraint(model, [tt = 1:T], (x[c.pxdim,tt] - c.x̃[c.pxdim,tt])^2 + (x[c.pydim,tt] - c.x̃[c.pydim,tt])^2  ≥ (c.δ)^2) 
end

# Check if this constraint is satisfied at each time. Return Boolean.
# Here, x (and x̃) is indexed `x[:, tt]`.
function is_satisfied(c::CoupledProximityConstraint, x)
    # TODO!
    T = size(x, 2)
    for tt in 1:T
        if  (x[c.pxdim,tt] - c.x̃[c.pxdim,tt])^2 + (x[c.pydim,tt] - c.x̃[c.pydim,tt])^2  < (c.δ)^2
            return false
        end
    end
    return true
end

# Plot this constraint on the existing plot `p`.
function plot_constraint!(c::CoupledProximityConstraint, p)
    T = last(size(c.x̃))

    # Make a circle at each time.
    θ = LinRange(0, 2π, 50)
    for tt in 1:T
        circle_xs = c.x̃[c.pxdim, tt] .+ c.δ * cos.(θ)
        circle_ys = c.x̃[c.pydim, tt] .+ c.δ * sin.(θ)

        # Plot the circle.
        plot!(p, circle_xs, circle_ys, seriestype=:shape, c=:red, fillalpha=:0.,
              linestyle=:dash, linealpha=:0.1, aspect_ratio=1, label="")

    end
end
