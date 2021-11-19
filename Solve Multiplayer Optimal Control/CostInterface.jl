# Interface for all optimal control costs.
# NOTE: This file should not need to be changed.
export Cost
abstract type Cost end

# Method for evaluating cost from a JuMP variable.
export evaluate
function evaluate end

# Coupled costs involve two different players.
export CoupledCost
abstract type CoupledCost <: Cost end

export other_player_idx
function other_player_idx(c::C) where C <: CoupledCost
    return c.other_player_idx
end
