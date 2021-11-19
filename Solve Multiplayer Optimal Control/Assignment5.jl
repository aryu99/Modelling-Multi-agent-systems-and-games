module Assignment5

# Utility for checking if JuMP termination status indicates success.
import JuMP
export is_converged
function is_converged(status)
    return status ∈ (JuMP.MOI.LOCALLY_SOLVED, JuMP.MOI.OPTIMAL)
end

# Optimal control.
include("DynamicsInterface.jl")
include("Unicycle.jl")
include("ConstraintInterface.jl")
include("ProximityConstraint.jl")
include("CostInterface.jl")
include("QuadraticCost.jl")
include("SolveOptimalControl.jl")

# Open loop games.
include("ProductDynamics.jl")
include("QuadraticDifferenceCost.jl")
include("CoupledProximityConstraint.jl")
include("SolveGame.jl")

end # module
