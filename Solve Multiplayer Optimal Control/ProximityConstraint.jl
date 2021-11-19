using JuMP: @constraint

# Struct for holding pertinent information for constraining proximity.
# NOTE: assuming a circular obstacle.
export ProximityConstraint
struct ProximityConstraint{T1 <: Real,T2 <: Integer} <: Constraint
    δ::T1     # Minimum proximity to obstacle center.
    px̂::T1    # Obstacle horizontal and vertical position values.
    pŷ::T1
    pxdim::T2 # Horizontal and vertical position dimensions in state `x`.
    pydim::T2
end

# Enforces that: ||(x, y) - (x̂, ŷ)|| ≥ δ.
# NOTE: recall that `x` is indexed `x[:, time]`
function add_constraints!(c::ProximityConstraint, model, x)
    # TODO!
    T = size(x, 2)
    @constraint(model, [tt = 1:T], (x[c.pxdim,tt] - c.px̂)^2 + (x[c.pydim,tt] -  c.pŷ)^2  ≥ (c.δ)^2)     
end

# Check if this constraint is satisfied at each time. Returns Boolean.
# Here, x is indexed `x[:, tt]`.
function is_satisfied(c::ProximityConstraint, x)
    # TODO!
    T = size(x, 2)
    for tt in 1:T
        if  (x[c.pxdim,tt] - c.px̂)^2 + (x[c.pydim,tt] -  c.pŷ)^2  < (c.δ)^2
            return false
        end
    end
    return true 
end

# Plot this constraint on the existing plot `p`.
function plot_constraint!(c::ProximityConstraint, p)
    # Make a circle.
    θ = LinRange(0, 2π, 50)
    circle_xs = c.px̂ .+ c.δ * cos.(θ)
    circle_ys = c.pŷ .+ c.δ * sin.(θ)

    # Plot the circle.
    plot!(p, circle_xs, circle_ys, seriestype=:shape, c=:red, fillalpha=:0.2,
          aspect_ratio=1, label="obstacle")
end