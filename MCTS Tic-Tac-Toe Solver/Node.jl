# Container for a Node in a tree. Each Node stores its parent and children, as
# well as the total value (for P1) for episodes passing through this Node,
# and the total number of episodes passing through.
# NOTE: this struct is mutable since we will be changing some fields throughout
#       tree search.
mutable struct Node
    b
    parent::Union{Nothing, Node}
    children::Dict
    total_value::Float64
    num_episodes::Int
end # struct

# Custom constructor from the given board.
Node(b; parent = nothing) = Node(b, parent, Dict(), 0.0, 0)
export Node
