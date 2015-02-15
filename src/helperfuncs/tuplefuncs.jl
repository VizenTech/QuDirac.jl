nfactors{N}(::NTuple{N}) = N
nfactors{N}(::Type{NTuple{N}}) = N

second(t::Tuple) = t[2]

#####################
# Joining Functions #
#####################
join_tup(items::Tuple) = apply(tuple, items...)
join_tup(items...) = join_tup(items)

separate(t::Tuple) = map(tuple, t)

######################
# Printing Functions #
######################
labelstr(label::Tuple) = strip(repr(label)[2:end-1], ',')

############################
# Combinatorical Functions #
############################
permute(t::Tuple, p::Array{Int}) = t[p]

function switch(t::Tuple, i, j)
    v = collect(t) 
    tmp = v[i]
    v[i] = v[j]
    v[j] = tmp
    return tuple(v...)
end

apply_at(f, arr, i) = join_tup(arr[1:i-1], f(arr[i]), arr[i+1:end])
except(arr, i) = join_tup(arr[1:i-1], arr[i+1:end])

# Placing here for now
digit_subscript(i::Int) = Base.REPLCompletions.latex_completions("\\_$i",3)[2][1][1]
subscript(i::Int) = reduce(*, reverse(map(digit_subscript, digits(i))))