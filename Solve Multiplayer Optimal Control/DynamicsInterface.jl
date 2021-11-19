# Interface for all dynamical systems.
# NOTE: This file should not need to be changed.
abstract type Dynamics end
abstract type SingleAgentDynamics <: Dynamics end
abstract type MultiAgentDynamics <: Dynamics end

# Method for adding dynamics constraints to a JuMP model.
#   - `x` is indexed `x[:, time]`
#   - `u` is indexed `u[:, time]`
export add_dynamics_constraints!
function add_dynamics_constraints! end

# Utilities for state and control dimensions.
export xdim, udim
function xdim end
function udim end

# Check if input sequence is feasible wrt. any present saturation limits.
export are_inputs_feasible
function are_inputs_feasible end

# Compute the next state given the current state and control input vectors.
# NOTE: nothing should be time-indexed in this function.
export next_x
function next_x end

# Utility to compute the state trajectory which arises when the given control
# sequence `u[:, time]` is applied from the given in initial state `x₁`.
export trajectory
function trajectory(dyn::D, x₁, u) where D <: SingleAgentDynamics
    # Unpack time horizon.
    T = last(size(u))

    # Generate state trajectory.
    x = zeros(xdim(dyn), T)
    x[:, 1] = x₁
    for tt in 2:T
        x[:, tt] = next_x(dyn, x[:, tt - 1], u[:, tt - 1])
    end

    return x
end

# Plot the given trajectory.
export plot_trajectory!
function plot_trajectory! end
