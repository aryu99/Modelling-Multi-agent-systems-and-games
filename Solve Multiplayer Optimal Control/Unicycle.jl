using JuMP: @variable, @constraint, @NLconstraint
using Plots: plot!

# Struct for holding Unicycle params.
export Unicycle
struct Unicycle{T <: AbstractFloat} <: SingleAgentDynamics
    # Time discretization.
    Δt::T

    # Upper and lower bounds for control inputs.
    ω̄::Union{Nothing, T}
    ω̲::Union{Nothing, T}
    ā::Union{Nothing, T}
    a̲::Union{Nothing, T}
end

Unicycle(Δt) = Unicycle(Δt, nothing, nothing, nothing, nothing)

# State and control dimensions.
function xdim(dyn::Unicycle)
    4
end

function udim(dyn::Unicycle)
    2
end

# Adding dynamics constraints for a Unicycle model, which has dynamics:
#                     [ px_{t+1} ]   [ px_t ]        [ v_t * cos(θ_t) ]
#           x_{t+1} = [ py_{t+1} ] = [ py_t ] + Δt * [ v_t * sin(θ_t) ]
#                     [ θ_{t+1}  ]   [ θ_t  ]        [ ω_t            ]
#                     [ v_{t+1}  ]   [ v_t  ]        [ a_t            ]
#
#           where u_t = [ ω_t ] (yaw rate)
#                       [ a_t ] (acceleration)
function add_dynamics_constraints!(dyn::Unicycle, model, x, u)
    T = size(x, 2)

    # Auxiliary variables for nonlinearities.
    cosθ = @variable(model, [1:T])
    @NLconstraint(model, [tt = 1:T], cosθ[tt] == cos(x[3, tt]))
    sinθ = @variable(model, [1:T])
    @NLconstraint(model, [tt = 1:T], sinθ[tt] == sin(x[3, tt]))

    # Enforce dynamic feasibility.
    @constraint(
        model,
        [tt = 1:(T - 1)],
        x[:, tt + 1] .== [
            x[1, tt] + dyn.Δt * x[4, tt] * cosθ[tt],
            x[2, tt] + dyn.Δt * x[4, tt] * sinθ[tt],
            x[3, tt] + dyn.Δt * u[1, tt],
            x[4, tt] + dyn.Δt * u[2, tt],
        ]
    )

    # Enforce control feasibility.
    if !isnothing(dyn.ω̄)
        @constraint(model, [tt = 1:T], u[1, tt] ≤ dyn.ω̄)
    end

    if !isnothing(dyn.ω̲)
        @constraint(model, [tt = 1:T], u[1, tt] ≥ dyn.ω̲)
    end

    if !isnothing(dyn.ā)
        @constraint(model, [tt = 1:T], u[2, tt] ≤ dyn.ā)
    end

    if !isnothing(dyn.a̲)
        @constraint(model, [tt = 1:T], u[2, tt] ≥ dyn.a̲)
    end
end

# Check if input sequence is feasible wrt. any present saturation limits.
function are_inputs_feasible(dyn::Unicycle, u)
    if !isnothing(dyn.ω̄) && any(u[1, :] .> dyn.ω̄)
        return false
    end

    if !isnothing(dyn.ω̲) && any(u[1, :] .< dyn.ω̲)
        return false
    end

    if !isnothing(dyn.ā) && any(u[2, :] .> dyn.ā)
        return false
    end

    if !isnothing(dyn.a̲) && any(u[2, :] .< dyn.a̲)
        return false
    end

    return true
end

# Compute next state which arises from the given state and control input.
# NOTE: must agree with the JuMP definition above.
# NOTE: here, state and control inputs are 1D arrays (sliced at a single time).
function next_x(dyn::Unicycle, x, u)
    # TODO!
    x_next = [x[1] + dyn.Δt * x[4]*cos(x[3]), 
            x[2] + dyn.Δt * x[4]*sin(x[3]), 
            x[3] + dyn.Δt * u[1],
            x[4] + dyn.Δt* u[2]]
    return x_next
    # print(test)
end

# Plot the given trajectory onto the given plot `p`.
function plot_trajectory!(dyn::Unicycle, p, x; color=:blue, label="")
    @assert first(size(x)) == xdim(dyn)

    s = x[4, :] * dyn.Δt
    plot!(p, x[1, :], x[2, :], xlabel="x (m)", ylabel="y (m)", color=:red,
          st=:quiver, quiver=(s .* cos.(x[3, :]), s .* sin.(x[3, :])))
    plot!(p, x[1, :], x[2, :], color=color, seriestype=:scatter, markersize=4,
          label=label)
end
