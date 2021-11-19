# Abstract types for Board and Move.
# NOTE: in this assignment we will assume that the game being played has
#       two players and that outcomes of the game are
#       P1 win (P2 loss), P1 loss (P2 win), tie.
abstract type Board end
export Board

abstract type Move end
export Move

# Specialization of Move to TicTacToe.
struct TicTacToeMove <: Move
    row::Int
    col::Int
end # struct
export TicTacToeMove

# A Board specialized for TicTacToe. Stores locations of the Xs and Os as
# tuples of integers. Presuming that X plays first, the size of these lists
# determines which player's turn it is.
mutable struct TicTacToeBoard <: Board
    Xs::AbstractArray{TicTacToeMove}
    Os::AbstractArray{TicTacToeMove}
end # struct

# Custom initialization to empty.
TicTacToeBoard() = TicTacToeBoard([], [])
export TicTacToeBoard

# Enumerate all possible next moves.
# TODO! Implement this function.
function next_moves(b::Board)
    empty_board = [TicTacToeMove(1,1),TicTacToeMove(1,2),TicTacToeMove(1,3),TicTacToeMove(2,1),TicTacToeMove(2,2),
    TicTacToeMove(2,3),TicTacToeMove(3,1),TicTacToeMove(3,2),TicTacToeMove(3,3)]
    for i in 1:length(b.Xs)
        filter!(e->e≠b.Xs[i],empty_board)
    end
    for j in 1:length(b.Os)
        filter!(e->e≠b.Os[j],empty_board)
    end   
    return empty_board
end
export next_moves

# Check if the given board is legal.
# TODO! Implement this function.
function is_legal(b::Board)
    for i in 1:length(b.Xs)
        if b.Xs[i].row >=4 || b.Xs[i].col >=4
            return false   
        end
    end
    for j in 1:length(b.Os)
        if b.Os[j].row >=4 || b.Os[j].col >=4
            return false
        end
    end

    if length(b.Os) > length(b.Xs)
        return false 
    end
    

    for i in 1:length(b.Xs)
        for j in 1:length(b.Os)
            if b.Xs[i]==b.Os[j]
                return false
            end
        end
    end
    return true
end
export is_legal

# Which player is up?
# TODO! Implement this function.
function up_next(b::Board)
    if length(b.Xs) == length(b.Os)
        return 1
    else
        return 2 
    end
end
export up_next

# Check if the game is over. If it is over, returns the outcome.
# TODO! Implement this function.
function is_over(b::Board)
    row1 = [TicTacToeMove(1,1), TicTacToeMove(1,2), TicTacToeMove(1,3)]
    row2 = [TicTacToeMove(2,1), TicTacToeMove(2,2), TicTacToeMove(2,3)]
    row3 = [TicTacToeMove(3,1), TicTacToeMove(3,2), TicTacToeMove(3,3)]
    col1 = [TicTacToeMove(1,1), TicTacToeMove(2,1), TicTacToeMove(3,1)]
    col2 = [TicTacToeMove(1,2), TicTacToeMove(2,2), TicTacToeMove(3,2)]
    col3 = [TicTacToeMove(1,3), TicTacToeMove(2,3), TicTacToeMove(3,3)]
    dia1 = [TicTacToeMove(1,1), TicTacToeMove(2,2), TicTacToeMove(3,3)]
    dia2 = [TicTacToeMove(1,3), TicTacToeMove(2,2), TicTacToeMove(3,1)]
    if issubset(row1, b.Xs) || issubset(row2, b.Xs) || issubset(row3, b.Xs) || issubset(col1, b.Xs) || issubset(col2, b.Xs) || issubset(col3, b.Xs) || issubset(dia1, b.Xs) || issubset(dia2, b.Xs)
        return (true, -1)
    elseif issubset(row1, b.Os) || issubset(row2, b.Os) || issubset(row3, b.Os) || issubset(col1, b.Os) || issubset(col2, b.Os) || issubset(col3, b.Os) || issubset(dia1, b.Os) || issubset(dia2, b.Os)
        return (true, 1)
    elseif length(b.Os) == 4 && length(b.Xs) == 5
        return (true, 0)
    else
        return (false, 0)
    end      
end
export is_over

# Utility for printing boards out to the terminal.
function Base.show(io::IO, b::TicTacToeBoard)
    for ii in 1:3
        for jj in 1:3
            m = TicTacToeMove(ii, jj)
            if m ∈ b.Xs
                print(" X ")
            elseif m ∈ b.Os
                print(" O ")
            else
                print(" - ")
            end
        end

        println()
    end
end
