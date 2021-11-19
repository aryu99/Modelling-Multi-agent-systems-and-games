import Ipopt
import JuMP
# using LinearAlgebra
using JuMP: @variable, @constraint, @NLconstraint

# Solve a Nash game in open-loop strategies.
# Inputs are:
#   - dyn: dynamics of the game in which each player has distinct state/input
#   - individual_state_costs: list of tuple of costs dependent on Pi's state
#   - coupled_state_costs: list of tuple of costs depending on Pi and Pj's state
#   - individual_state_constraints: list of tuple of costs dependent on Pi's state
#   - coupled_state_constraints: list of tuple of costs depending on Pi and Pj's state
#   - control_costs: analogous to individual_state_costs, but for control
#   - x₁: initial state for all players [player][:]
#   - T: time horizon
#   - max_ibr_iters: maximum rounds of iterated best response
#   - ibr_tol: tolerance used to check if IBR has converged
# Return lists of arrays, and overall success:
#   (xs[player][:, time], us[player][:, time], success)
export solve_game
function solve_game(dyn::ProductDynamics,
                    individual_state_costs::AbstractArray,
                    coupled_state_costs::AbstractArray,
                    individual_state_constraints::AbstractArray,
                    coupled_state_constraints::AbstractArray,
                    control_costs::AbstractArray,
                    x₁,
                    T;
                    max_ibr_iters = 10,
                    ibr_tol = 1e-3)
    # Unpack dimensions.
    n = xdim(dyn)
    m = udim(dyn)

    # Unpack number of subsystems / players.
    N = num_players(dyn)
    @assert N == length(individual_state_costs)
    @assert N == length(coupled_state_costs)
    @assert N == length(coupled_state_constraints)
    @assert N == length(control_costs)

    # Pre-solve each player's problem independently, neglecting coupling costs.
    # We will use these as an initialization.
    # Cache results.
    last_xs = [zeros(n, T) for _ in 1:N]
    last_us = [zeros(m, T) for _ in 1:N]
    for ii in 1:N
        x̃, ũ, _, success = solve_optimal_control(
            dyn.subsystems[ii],
            individual_state_costs[ii],
            individual_state_constraints[ii],
            control_costs[ii],
            x₁[ii],
            T
        )

        @assert success
        last_xs[ii] = x̃
        last_us[ii] = ũ
    end

    # println(last_xs)
    # println(last_us)

    # Main loop. Iterate through players and, sequentially, set an objective and
    # solve the corresponding optimal control problem.
    current_xs = deepcopy(last_xs)
    current_us = deepcopy(last_us)

    for iter in 1:max_ibr_iters
        println("test")
        for ii in 1:N
            # Update coupled state costs and constraints so that their `x̃` field
            # reflects the most up-to-date state traj of the appropriate player.

            # TODO!
            
            index_x = coupled_state_costs[ii].attract_x.other_player_idx
            # println(index_x)
            # coupled_state_costs[ii].attract_x.x̃ = current_xs[index_x]
            # index_y = coupled_state_costs[ii].attract_y.other_player_idx
            # coupled_state_costs[ii].attract_y.x̃ = current_xs[index_y]
            
            for cost in coupled_state_costs[ii]
                cost.x̃ = last_xs[cost.other_player_idx]
                # println("bbbb ", cost.x̃ )
            end

            # for c in coupled_state_constraints[ii]
            #     # println("bbbb")
            #     println(c.other_player_idx)
            #     c.x̃ = last_xs[c.other_player_idx]
            # end
           
            coupled_state_constraints[index_x].proximity.x̃ = current_xs[index_x]

            player_state_cost = []

            # Indivdual costs + coupled costs
            for i in 1:length(individual_state_costs)
                if i == ii
                    for keys in individual_state_costs[i]
                        # println(keys)
                        push!(player_state_cost,keys)
                    end
                end
            end

          

            for i in 1:length(coupled_state_costs)
                if i == ii
                    for keys in coupled_state_costs[i]
                        push!(player_state_cost,keys)
                    end
                end
            end
        
           

            ### Indivdual constraints + Coupled State constraints

            player_state_constraints = []

            for i in 1:length(individual_state_constraints)
                if i == ii
                    for keys in individual_state_constraints[i]
                        # println(keys)
                        push!(player_state_constraints,keys)
                    end
                end
            end
            

            for i in 1:length(coupled_state_constraints)
                if i == ii
                    for keys in coupled_state_constraints[i]
                        # println(keys)
                        push!(player_state_constraints,keys)
                    end
                end
            end

            # println("player-constraint ", player_state_constraints)
        

            ### 

            # Solve updated problem.
            x̃, ũ, _, success = solve_optimal_control(
                dyn.subsystems[ii],
                player_state_cost,
                player_state_constraints,
                control_costs[ii],
                current_xs[ii],
                T)

            # Check convergence of this solve.
            if !success
                @warn "OCP for P" * string(ii) * " did not converge."
                break
            end

            # Keep current cache up to date.
            current_xs[ii] = x̃
            current_us[ii] = ũ
        end

        # Compare solutions after this round to previous solutions and terminate
        # if IBR has converged, i.e. |xs[ii] - last_xs[ii]| < ibr_tol (and same
        # for controls).
        # TODO!

        is_done = false
        # println(size(current_xs[1]))
        # println(current_xs[1])

        println("abababa")

        list = []

        for jj in 1:N
            push!(list,norm(current_xs[jj] - last_xs[jj]) < ibr_tol &&  norm(current_us[jj] - last_us[jj]) < ibr_tol)
            if false in list
                pass
            else
                is_done = true
            end
        end
        
        
        # Update cached solutions.
        last_xs = current_xs
        last_us = current_us

        if is_done == true
            break
        end

        
    end

    # @warn "IBR did not converge."
    return last_xs, last_us, true
end