# Solve a finite horizon, discrete time LQ game to feedback Nash equilibrium.
# Returns feedback matrices P[player][:, :, time]
# TODO!
export solve_lq_feedback
function solve_lq_feedback(dyn::Dynamics, costs::AbstractArray{Cost}, horizon::Int)

    global Q_i = costs[1].Q
    global Q_j = costs[2].Q
    global Ps_1 = []
    global Ps_2 = []

    for i in 1:horizon

        A = dyn.A
        B_i = dyn.Bs[1]
        B_j = dyn.Bs[2]
        
        R_i = costs[1].Rs[1]
        R_j = costs[2].Rs[2]    
    
        X_11 = R_i + (transpose(B_i) * Q_i * B_i)
        X_12 = transpose(B_i) * Q_i * (B_j)
        X_1 = hcat(X_11, X_12)    
        X_21 = transpose(B_j) * Q_j * (B_i)
        X_22 = R_j + (transpose(B_j) * Q_j * B_j)
        X_2 = hcat(X_21, X_22)
        X = vcat(X_1, X_2)
        Z_1 = transpose(B_i) * Q_i * A
        Z_2 = transpose(B_j) * Q_j * A
        Z = vcat(Z_1, Z_2)

        P = X \ Z  


        if i == 1
            Ps_1 = P[[1, 2], :]
            Ps_2 = P[[3, 4], :]
        else
            Ps_1 = cat(P[[1, 2], :], Ps_1, dims = 3)
            Ps_2 = cat(P[[3, 4], :], Ps_2, dims = 3)
        end

        first_i = costs[1].Q - ((transpose(P[[1, 2], :]) * R_i * P[[1, 2], :]) + (transpose(P[[3, 4], :]) * R_j * P[[3, 4], :]))
        first_j = costs[2].Q - ((transpose(P[[1, 2], :]) * R_i * P[[1, 2], :]) + (transpose(P[[3, 4], :]) * R_j * P[[3, 4], :]))

        Q_i = first_i + (transpose(A - ((B_i * P[[1, 2], :]) + (B_j * P[[3, 4], :]))) * Q_i * (A - ((B_i * P[[1, 2], :]) + (B_j * P[[3, 4], :]))))
        Q_j = first_j + (transpose(A - ((B_i * P[[1, 2], :]) + (B_j * P[[3, 4], :]))) * Q_j * (A - ((B_i * P[[1, 2], :]) + (B_j * P[[3, 4], :])))) 
    end
    
    Ps = [Ps_1, Ps_2]

    return Ps
end



    


