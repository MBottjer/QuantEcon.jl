#=
Generate a MarkovChain randomly.

@author : Daisuke Oyama

=#
import StatsBase: sample
import QuantEcon: MarkovChain


# random_markov_chain

"""
Return a randomly sampled MarkovChain instance with n states.

##### Arguments

- `n::Integer` : Number of states.

##### Returns

- `mc::MarkovChain` : MarkovChain instance.

##### Examples

```julia
julia> using QuantEcon

julia> mc = random_markov_chain(3)
Discrete Markov Chain
stochastic matrix:
3x3 Array{Float64,2}:
 0.281188  0.61799   0.100822
 0.144461  0.848179  0.0073594
 0.360115  0.323973  0.315912

```

"""
function random_markov_chain(n::Integer)
    p = random_stochastic_matrix(n)
    mc = MarkovChain(p)
    return mc
end


"""
Return a randomly sampled MarkovChain instance with n states, where each state
has k states with positive transition probability.

##### Arguments

- `n::Integer` : Number of states.

##### Returns

- `mc::MarkovChain` : MarkovChain instance.

##### Examples

```julia
julia> using QuantEcon

julia> mc = random_markov_chain(3, 2)
Discrete Markov Chain
stochastic matrix:
3x3 Array{Float64,2}:
 0.369124  0.0       0.630876
 0.519035  0.480965  0.0
 0.0       0.744614  0.255386

```

"""
function random_markov_chain(n::Integer, k::Integer)
    p = random_stochastic_matrix(n, k)
    mc = MarkovChain(p)
    return mc
end


# random_stochastic_matrix

"""
Return a randomly sampled n x n stochastic matrix.

##### Arguments

- `n::Integer` : Number of states.
- `k::Integer` : Number of nonzero entries in each row of the matrix.

##### Returns

- `p::Array` : Stochastic matrix.

"""
function random_stochastic_matrix(n::Integer)
    if n <= 0
        throw(ArgumentError("n must be a positive integer"))
    end

    p = random_probvec(n, n)

    return transpose(p)
end


"""
Return a randomly sampled n x n stochastic matrix with k nonzero entries for
each row.

##### Arguments

- `n::Integer` : Number of states.
- `k::Integer` : Number of nonzero entries in each row of the matrix.

##### Returns

- `p::Array` : Stochastic matrix.

"""
function random_stochastic_matrix(n::Integer, k::Integer)
    if !(n > 0)
        throw(ArgumentError("n must be a positive integer"))
    end
    if !(k > 0 && k <= n)
        throw(ArgumentError("k must be an integer with 0 < k <= n"))
    end

    k == n && return random_stochastic_matrix(n)

    # if k < n
    probvecs = random_probvec(k, n)

    # Randomly sample row indices for each column for nonzero values
    row_indices = @compat Vector{Int}(k*n)
    for j in 1:n
        row_indices[(j-1)*k+1:j*k] = sample(1:n, k, replace=false)
    end

    p = zeros(n, n)
    for j in 1:n
        for i in 1:k
            p[row_indices[(j-1)*k+i], j] = probvecs[i, j]
        end
    end

    return transpose(p)
end


# random_probvec

"""
Return m randomly sampled probability vectors of size k.

##### Arguments

- `k::Integer` : Number of probability vectors.
- `m::Integer` : Size of each probability vectors.

##### Returns

- `a::Array` : Array of shape (k, m) containing probability vectors as colums.

"""
function random_probvec(k::Integer, m::Integer)
    x = Array(Float64, (k+1, m))

    r = rand(k-1, m)
    x[1, :], x[2:end-1, :], x[end, :] = 0, sort(r, 1), 1
    return diff(x, 1)
end
