# Interface for all optimal control state constraints.
# NOTE: This file should not need to be changed.
export Constraint
abstract type Constraint end

# Method for adding constraints to a JuMP model.
export add_constraints!
function add_constraints! end

# Method to check if constraints are satisfied.
export is_satisfied
function is_satisfied end

# Method to plot a single constraint.
export plot_constraint!
function plot_constraint! end

# Utility for plotting.
export plot_constraints!
function plot_constraints!(constraints, p)
    for c in constraints
        plot_constraint!(c, p)
    end
end

# Coupled constraints involve two players.
export CoupledConstraint
abstract type CoupledConstraint <: Constraint end

export other_player_idx
function other_player_idx(c::C) where C <: CoupledConstraint
    return c.other_player_idx
end
