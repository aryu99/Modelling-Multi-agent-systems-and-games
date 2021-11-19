using Assignment3

A = [1 0.1 0 0;
    0 1   0 0;
    0 0   1 1.1;
    0 0   0 1]
B₁ = [0 0.1 0 0]'
B₂ = [0 0   0 0.1]'
dyn = Dynamics(A, [B₁, B₂])

Q₁ = [0 0 0  0;
        0 0 0  0;
        0 0 1. 0;
        0 0 0  0]
c₁ = Cost(Q₁)
add_control_cost!(c₁, 1, ones(1, 1))

Q₂ = [1.  0 -1 0;
        0  0 0  0;
        -1 0 1  0;
        0  0 0  0]
c₂ = Cost(Q₂)
add_control_cost!(c₂, 2, ones(1, 1))

costs = [c₁, c₂]

x₁ = [1., 0, 1, 0]

# function test(dyn::Dynamics, costs::AbstractArray{Cost})
J_i = costs[1]
J_j = costs[2]
# T = horizon

A = dyn.A
B_i = dyn.Bs[1]
B_j = dyn.Bs[2]
Q_i = J_i.Q
Q_j = J_j.Q
R_i = J_i.Rs[1]
R_j = J_j.Rs[2]


# while (T-1) != 0
L_i = R_i + (transpose(B_i) * Q_i * B_i)
L_j = R_j + (transpose(B_j) * Q_j * B_j)
M_i = transpose(B_i) * Q_i * (B_j)
M_j = transpose(B_j) * Q_j * (B_i)
N_i = transpose(B_i) * Q_i * A
N_j = transpose(B_j) * Q_j * A
X = Array{Array, 2}(undef, 2, 2)
P = Array{Array, 1}(undef, 2)
Z = Array{Array, 1}(undef, 2)
X[1,1] = L_i
X[1,2] = M_i
X[2,1] = L_j
X[2,2] = M_j
Z[1] = N_i
Z[2] = N_j
println(typeof(X), X)
# println("Z", Z)
P = Z * (inv(X))
J_i.Q = transpose(A - (B_j * P[2])) * Q_i * (A - (B_j*P[2]))
J_j.Q = transpose(A - (B_i * P[1])) * Q_j * (A - (B_i*P[1]))
costs = [J_i, J_j]
    # T = T - 1
    # solve_lq_feedback(dyn::Dynamics, costs, T)
    # end
#     return P
# end