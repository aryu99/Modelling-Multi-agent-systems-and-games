# import Ipopt
# import JuMP 
# using JuMP
# # using JuMP: @variable, @NLconstraint, @objective


# # Solve optimal control problem with given:
# #   - dynamics
# #   - state costs
# #   - control costs
# #   - state constraints
# #   - initial condition `x₁`
# #   - time horizon `T`
# # Return a tuple of
# #   (state trajectory, control trajectory, objective value, termination status).
# # NOTE: using `Ipopt.Optimizer` as the underlying solver.
# export solve_optimal_control
# function solve_optimal_control(dyn, state_costs, state_constraints, control_costs, x₁, T)

#     model = JuMP.Model(Ipopt.Optimizer)
#     JuMP.set_optimizer_attribute(model, "print_level", 3)

#     @variable(model,x[1:xdim(dyn),1:T])
#     @variable(model,u[1:udim(dyn),1:T])

#     add_dynamics_constraints!(dyn,model,x,u)

#     @constraint(model,x[1:xdim(dyn),1] .== x₁)

#     for cons in 1:length(state_constraints)
#         add_constraints!(state_constraints[cons], model, x)
#     end

#     costs = sum(evaluate(control_costs[i], x) for i in 1:length(state_costs)) +
#         sum(evaluate(control_costs[j], u) for j in 1:length(control_costs))

#     @objective(model,Min,costs)

#     optimize!(model)

#     return (JuMP.value.(model[:x]), JuMP.value.(model[:u]), JuMP.objective_value(model), 
#             is_converged(JuMP.termination_status(model)))
   
# end

import Ipopt
import JuMP
using JuMP

# Solve optimal control problem with given:
#   - dynamics
#   - state costs
#   - control costs
#   - state constraints
#   - initial condition `x₁`
#   - time horizon `T`
# Return a tuple of
#   (state trajectory, control trajectory, objective value, termination status).
# NOTE: using `Ipopt.Optimizer` as the underlying solver.
export solve_optimal_control
function solve_optimal_control(
    dyn, state_costs, state_constraints, control_costs, x₁, T)
    # Unpack dimensions.
    n = xdim(dyn)
    m = udim(dyn)
    
    # Initialize a JuMP model.
    model = JuMP.Model(Ipopt.Optimizer)
    JuMP.set_optimizer_attribute(model, "print_level", 3)

    # decision variable

    @variable(model,x[1:n,1:T])
    @variable(model,u[1:m,1:T])

    add_dynamics_constraints!(dyn,model,x,u)

    @constraint(model,x[1:n,1:1] .== x₁)

    for field in keys(state_constraints)
        val = state_constraints[field]
        add_constraints!(val,model,x)
    end

    ## Minimise J as the objective function

    objective = 0
    for ii in state_costs
        objective += evaluate(ii,x)
    end
      
    for jj in control_costs 
        objective += evaluate(jj,u)
    end
    

    # Objective
    @objective(model,Min,objective)

    # Dynamics
    optimize!(model)
    return (JuMP.value.(model[:x]),
            JuMP.value.(model[:u]),
            JuMP.objective_value(model),
            is_converged(JuMP.termination_status(model)))
   
end
