# Construct a Monte Carlo search tree from the given board.
# Should accept an optional argument T which specifies the number of seconds
# spent in tree construction.
# For reference: https://en.wikipedia.org/wiki/Monte_Carlo_tree_search
# TODO! Implement this function.
function construct_search_tree(b;T=0.1)
    time = 0    
    root = Node(b)
    while time < T
    time += @elapsed begin
            leaf = find_leaf(root, upper_confidence_strategy)
            x,y = simulate(leaf)
            backpropagate!(x,y)
        end
    end
    return root
        
end
export construct_search_tree        


# Upper confidence strategy. Takes in a set of Nodes and returns one
# consistent with the UCT rule (see earlier reference for details).
# TODO! Implement this function.
function uct_val(n::Node)
    c = sqrt(2)
    uct = (n.total_value/n.num_episodes) + (c * (sqrt(log(n.parent.num_episodes)/n.num_episodes)))
    return uct    
end

function upper_confidence_strategy(n::Node)
    uct_dict = Dict()
    for (key, value) in n.children
        uct_dict[value] = uct_val(value)  
    end
    x = argmax(uct_dict)
    return x
end
export upper_confidence_strategy

# Walk the tree to find a leaf Node, choosing children at each level according
# to the function provided, whose signature is Foo(Node)::Node,
# such as the upper_confidence_strategy.
# TODO! Implement this function.
function find_leaf(n::Node, upper_confidence_strategy)
    if (length(n.children) != 0) && (length(n.children) == length(next_moves(n.b)))
        return find_leaf(upper_confidence_strategy(n), upper_confidence_strategy)
    else    
        return n
    end

end
export find_leaf

# Simulate gameplay from the given (leaf) node.
# TODO! Implement this function.
function simulate(leaf::Node)
    node, score = is_over(leaf.b)
    if node == true
        return leaf, score
    end
    
    child = rand(next_moves(leaf.b))
    child_b = deepcopy(leaf.b)
    if haskey(leaf.children, child) == false        
            if up_next(leaf.b) == 1
                push!(child_b.Xs, child)
                leaf.children[child] = Node(child_b, parent = leaf) 
            elseif up_next(leaf.b) == 2
                push!(child_b.Os, child)
                leaf.children[child] = Node(child_b, parent = leaf)
            end

    end
    
    if is_over(child_b) == (false,0)
       return simulate(leaf.children[child])
    end
    return leaf.children[child], is_over(child_b)[2]
end
export simulate

# Backpropagate values up the tree from the given (leaf) node.
# TODO! Implement this function.
function backpropagate!(t_node::Node, w::Int64)
    t_node.num_episodes += 1 
    if (up_next(t_node.b) == 2 && w == -1) || (up_next(t_node.b) == 1 && w == 1)
        t_node.total_value += 1
    elseif w == 0
        t_node.total_value += 0.5
    else 
        t_node.total_value += 0
    end
    if t_node.parent != nothing
        backpropagate!(t_node.parent, w)
    end
end
export backpropagate!

# Play a game! Parameterized by time given to the CPU. Assumes CPU plays first.
export play_game
function play_game(; T = 0.1)
    b = TicTacToeBoard()

    result = 0
    while true
        # CPU's turn.
        root = construct_search_tree(b, T = T)
        b = upper_confidence_strategy(root).b

        # Display board.
        println(b)

        over, result = is_over(b)
        if over
            break
        end

        # Query user for move.
        println("Your move! Row = ?")
        row = parse(Int, readline())
        println("Column = ?")
        col = parse(Int, readline())

        # Construct next board state and repeat.
        m = TicTacToeMove(row, col)
        push!(b.Os, m)
        @assert is_legal(b)

        over, result = is_over(b)
        if over
            break
        end
    end

    println("Game over!")
    if result == -1
        println("I won!")
    elseif result == 0
        println("Tie game.")
    else
        println("You won.")
    end
end
