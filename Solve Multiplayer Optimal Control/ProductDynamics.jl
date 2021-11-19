# NOTE: this file should not need to be modified.
using ColorSchemes: inferno

# Utilities for managing systems composed of subsystems, i.e., N agents each
# with separate state variables concatenated together.
export ProductDynamics
struct ProductDynamics{D} <: MultiAgentDynamics where D <: SingleAgentDynamics
    # List of subsystems, each of which implements the DynamicsInterface.
    # NOTE: all subsystems must be of the same type, for simplicity.
    subsystems::AbstractArray{D}
end

# Method for adding dynamics constraints to a JuMP model.
#   - `xs` is indexed `xs[player][:, time]`
#   - `us` is indexed `us[player][:, time]`
function add_dynamics_constraints!(dyn::ProductDynamics, models, xs, us)
    @warn "This function should not be used directly."
end

# Utilities for state and control dimensions.
function xdim(dyn::ProductDynamics)
    xdim(dyn.subsystems[1])
end

function udim(dyn::ProductDynamics)
    udim(dyn.subsystems[1])
end

# Number of agents.
function num_players(dyn::ProductDynamics)
    length(dyn.subsystems)
end

# Check if input sequence is feasible wrt. any present saturation limits.
# Indexing is `u[player, :, time]`.
function are_inputs_feasible(dyn::ProductDynamics, u)
    @assert first(size(u)) == num_players(dyn)
    for ii in 1:num_players(dyn)
        if !are_inputs_feasible(dyn.subsystems[ii], u[ii, :, :])
            return false
        end
    end

    return true
end

# Compute the next state given the current state and control input vectors.
# NOTE: nothing should be time-indexed in this function.
# NOTE: states are indexed `x[player, :]`
function next_x(dyn::ProductDynamics, x, u)
    N = num_players(dyn)
    x⁺ = [next_x(dyn.subsystems[ii], x[ii], u[ii]) for ii in 1:N]

    return x⁺
end

# Utility to compute the state trajectory which arises when the given control
# sequences `us[player][:, time]` is applied from the given in initial states
# `x₁[player][:]` (for each player).
function trajectory(dyn::ProductDynamics, x₁, us)
    # Unpack time horizon and num players.
    T = last(size(us[1]))
    N = num_players(dyn)

    # Set initial condition.
    xs = [zeros(xdim(dyn), T) for _ in 1:N]
    for ii in 1:N
        xs[ii][:, 1] = x₁[ii]
    end

    # Generate state trajectory.
    x = x₁
    for tt in 2:T
        u = [us[ii][:, tt - 1] for ii in 1:N]
        x = next_x(dyn, x, u)
        for ii in 1:N
            xs[ii][:, tt] = x[ii]
        end
    end

    return xs
end

# Plot the given trajectory onto the given plot `p`.
# `xs` should be indexed [player][:, time].
function plot_trajectory!(dyn::ProductDynamics, p, xs)
    N = length(dyn.subsystems)

    for ii in 1:N
        plot_trajectory!(dyn.subsystems[ii], p, xs[ii][:, :],
                         color=inferno[(1. * ii - 1) / N],
                         label="Player " * string(ii))
    end
end
