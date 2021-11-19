# Solve a finite horizon, discrete time LQ game to open-loop Nash equilibrium.
# Returns the trajectory of states xs[:, time] and controls us[player][:, time].
# NOTE: must provide the initial state x₁ here.
#       Why didn't we need it in the feedback case?
export solve_lq_open_loop
using LinearAlgebra
function solve_lq_open_loop(dyn::Dynamics, costs::AbstractArray{Cost}, horizon::Int, x₁)

    A = dyn.A
    B_i = dyn.Bs[1]
    B_j = dyn.Bs[2]

    R_i = costs[1].Rs[1]
    R_j = costs[2].Rs[2]
    Q_i = costs[1].Q
    Q_j = costs[2].Q

    global lamda_list = Array{Matrix{Float64}}(undef, 1, horizon)
    global M_i_list = Array{Matrix{Float64}}(undef, 1, horizon)
    global M_j_list = Array{Matrix{Float64}}(undef, 1, horizon)
    global u_i_list = Array{Vector{Float64}}(undef, 1, horizon)
    global u_j_list = Array{Vector{Float64}}(undef, 1, horizon)
    global x_t_list = Array{Vector{Float64}}(undef, 1, horizon)
    # println(size((B_i*(inv(R_i))*(transpose(B_i))*Q_i) + (B_j*(inv(R_j))*(transpose(B_j))*Q_j)))
    for i in 1:horizon 
        if i == 1
            lamda = Matrix(I, 8, 8) + ((B_i*(inv(R_i))*(transpose(B_i))*Q_i) + (B_j*(inv(R_j))*(transpose(B_j))*Q_j))
            lamda_list[1,i] = lamda

            M_i = Q_i + transpose(A)*Q_i*(inv(lamda))*A
            M_i_list[1,i] = M_i

            M_j = Q_j + transpose(A)*Q_j*(inv(lamda))*A
            M_j_list[1,i] = M_j
        else
            lamda = Matrix(I, 8, 8) + ((B_i*(inv(R_i))*(transpose(B_i))*M_i_list[1, i-1]) + (B_j*(inv(R_j))*(transpose(B_j))*M_j_list[1, i-1]))
            lamda_list[1,i] = lamda

            M_i = Q_i + transpose(A)*M_i_list[1, i-1]*(inv(lamda))*A
            M_i_list[1,i] = M_i

            M_j = Q_j + transpose(A)*M_j_list[1, i-1]*(inv(lamda))*A
            M_j_list[1,i] = M_j
        end
    end

    for j in 1:horizon
        if j == 1
            x_t = inv(lamda_list[1, horizon]) * A * x₁
            x_t_list[1,j] = x_t

            u_i = (-(inv(R_i))) * transpose(B_i) * M_i_list[1, horizon] * x_t
            u_i_list[1,j] = u_i

            u_j = (-(inv(R_j))) * transpose(B_j) * M_j_list[1, horizon] * x_t
            u_j_list[1,j] = u_j

        else
            x_t = inv(lamda_list[1, length(lamda_list) - (j - 1)]) * A * x_t_list[1, j - 1]
            x_t_list[1,j] = x_t

            u_i = (-(inv(R_i))) * transpose(B_i) * (M_i_list[1, length(M_i_list) - (j - 1)]) * x_t
            u_i_list[1,j] = u_i

            u_j = (-(inv(R_j))) * transpose(B_j) * (M_j_list[1, length(M_j_list) - (j - 1)]) * x_t
            u_j_list[1,j] = u_j
        end        
    end
    #Just rearranging the matrix elements according to the format thats required to be returned
    # println(size(u_i_list))
    # println(u_i_list)
    cat_ui = []
    cat_uj = []
    for v in 1:length(u_i_list)
        if v==1
            cat_ui = u_i_list[1]
            cat_uj = u_j_list[1]
        else
            cat_ui = hcat(cat_ui, u_i_list[v])
            cat_uj = hcat(cat_uj, u_j_list[v])
        end
    end
    # println(size(cat_ui))
    # println(cat_ui)

    us = [cat_ui, cat_uj]
    # println(cat_ui)
    # println(size(x_t_list))
    # println(x_t_list)
    one_x = Array{Float64}(undef, 8, 50)

    # println(x_t_list)
    # one_x = [x_t_list[1,1][1]; x_t_list[1,1][2]; x_t_list[1,1][3]; x_t_list[1,1][4]]
    for z in 1:horizon
        for y in 1:8
            one_x[y, z] = x_t_list[1, z][y]
        end
    end
    #     one_x = hcat(one_x, [x_t_list[1,1][1]; x_t_list[1,1][2]; x_t_list[1,1][3]; x_t_list[1,1][4]])
    # end
    
    return one_x, us  
    
end
