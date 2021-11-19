# Utilities for Assignment 3. You should not need to modify this file.

# Cost for a single player.
# Form is: x^T_t Q^i x + \sum_j u^{jT}_t R^{ij} u^j_t.
# For simplicity, assuming that Q, R are time-invariant, and that dynamics are
# linear time-invariant, i.e. x_{t+1} = A x_t + \sum_i B^i u^i_t.
mutable struct Cost
    Q
    Rs # Nonzero R^{ij} for Pi.
end

function Cost(Q)
    Cost(Q, Dict{Int, Matrix{eltype(Q)}}())
end
export Cost

# Method to add R^{ij}s to a Cost struct.
export add_control_cost!
function add_control_cost!(c::Cost, other_player_idx, Rij)
    c.Rs[other_player_idx] = Rij
end

# Evaluate cost on a state/control trajectory.
# - xs[:, time]
# - us[player][:, time]
export evaluate
function evaluate(c::Cost, xs, us)
    horizon = last(size(xs))

    total = 0.0

    for tt in 1:horizon

        total += xs[:, tt]' * c.Q * xs[:, tt]
        total += sum(us[jj][:, tt]' * Rij * us[jj][:, tt] for (jj, Rij) in c.Rs)

    end

    return total
end

# Dynamics.
export Dynamics
struct Dynamics
    A
    Bs
end

export xdim
function xdim(dyn::Dynamics)
    return first(size(dyn.A))
end

export udim
function udim(dyn::Dynamics)
    return sum(last(size(B)) for B in dyn.Bs)
end

function udim(dyn::Dynamics, player_idx)
    return last(size(dyn.Bs[player_idx]))
end

# Function to unroll a set of feedback matrices from an initial condition.
# Output is a sequence of states xs[:, time] and controls us[player][:, time].
export unroll_feedback
function unroll_feedback(dyn::Dynamics, Ps, x₁)
    @assert length(x₁) == xdim(dyn)

    N = length(Ps)
    @assert N == length(dyn.Bs)

    horizon = last(size(first(Ps)))

    # Populate state/control trajectory.
    xs = zeros(xdim(dyn), horizon)
    xs[:, 1] = x₁
    us = [zeros(udim(dyn, ii), horizon) for ii in 1:N]
    for tt in 2:horizon
        for ii in 1:N
            
            
            us[ii][:, tt - 1] = -Ps[ii][:, :, tt - 1] * xs[:, tt - 1]
        end

        xs[:, tt] = dyn.A * xs[:, tt - 1] + sum(
            dyn.Bs[ii] * us[ii][:, tt - 1] for ii in 1:N)
    end

    # Controls at final time.
    for ii in 1:N
        us[ii][:, horizon] = -Ps[ii][:, :, horizon] * xs[:, horizon]
    end

    return xs, us
end

# As above, but replacing feedback matrices `P` with raw control inputs `u`.
export unroll_open_loop
function unroll_open_loop(dyn::Dynamics, us, x₁)
    @assert length(x₁) == xdim(dyn)

    N = length(us)
    @assert N == length(dyn.Bs)

    horizon = last(size(first(us)))

    # Populate state trajectory.
    xs = zeros(xdim(dyn), horizon)
    xs[:, 1] = x₁
    us = [zeros(udim(dyn, ii), horizon) for ii in 1:N]
    for tt in 2:horizon
        xs[:, tt] = dyn.A * xs[:, tt - 1] + sum(
            dyn.Bs[ii] * us[ii][:, tt - 1] for ii in 1:N)
    end

    return xs
end
