[![Build Status](https://travis-ci.org/JuliaQuantum/QuDirac.jl.svg?branch=master)](https://travis-ci.org/JuliaQuantum/QuDirac.jl)
# QuDirac.jl

QuDirac.jl is a [Julia](http://julialang.org/) library for using Dirac notation to perform 
quantum mechanics computations. 

## Features

Below are some toy examples; actual documentation is coming soon! 

#### State types (`Ket`,`Bra`) and Operator types (`OpSum`,`OuterProduct`)

```julia
julia> bell = 1/√2 * (ket(0,0) + ket(1,1))
Ket{KroneckerDelta,2,Float64} with 2 state(s):
  0.7071067811865475 | 0,0 ⟩
  0.7071067811865475 | 1,1 ⟩

julia> bell'
Bra{KroneckerDelta,2,Float64} with 2 state(s):
  0.7071067811865475 ⟨ 0,0 |
  0.7071067811865475 ⟨ 1,1 |

julia> op = bell * bell'
OuterProduct with 4 operator(s); Ket{KroneckerDelta,2,Float64} * Bra{KroneckerDelta,2,Float64}:  
  0.4999999999999999 | 0,0 ⟩⟨ 0,0 |
  0.4999999999999999 | 0,0 ⟩⟨ 1,1 |
  0.4999999999999999 | 1,1 ⟩⟨ 0,0 |
  0.4999999999999999 | 1,1 ⟩⟨ 1,1 |

julia> ptrace(op, 1)
OpSum{KroneckerDelta,1,Float64} with 2 operator(s):
  0.4999999999999999 | 0 ⟩⟨ 0 |
  0.4999999999999999 | 1 ⟩⟨ 1 |
```

#### Support for abstract inner products

```julia
# tells QuDirac to use the rule for undefined inner products
julia> default_inner(UndefinedInner())
INFO: QuDirac's default inner product type is currently UndefinedInner()

julia> k = 1/√2 * (ket('a') + ket('b'))
Ket{UndefinedInner,1,Float64} with 2 state(s):
  0.7071067811865475 | 'b' ⟩
  0.7071067811865475 | 'a' ⟩

julia> bra('a') * k
((0.7071067811865475 * ⟨ 'a' | 'b' ⟩) + (0.7071067811865475 * ⟨ 'a' | 'a' ⟩))
```

#### Custom inner product rules

```julia
julia> immutable MyInner <: AbstractInner end

julia> QuDirac.inner_rule(::MyInner, ktlabel, brlabel) = sqrt(ktlabel[1]+brlabel[1])
inner_rule (generic function with 3 methods)

julia> default_inner(MyInner())
INFO: QuDirac's default inner product type is currently MyInner()

julia> bra(π) * ket(e) # eval ⟨ π | e ⟩ with MyInner rule -> sqrt(π + e)
2.420717761749361
```

#### Functional Operator Construction

For example, here's the functional definition of a lowering operator 
on the second factor of a 3-factor number basis: 

```julia
julia> @def_op " â₂ | x, y, z > = √y * | x, y - 1, z > "
â₂ (generic function with 2 methods)

julia> k = sum(i -> ket(i, i, i), 1:10)
Ket{KroneckerDelta,3,Int64} with 10 state(s):
  1 | 8,8,8 ⟩
  1 | 9,9,9 ⟩
  1 | 10,10,10 ⟩
  1 | 2,2,2 ⟩
  1 | 7,7,7 ⟩
  ⁞

# functions generated using @def_op can be applied 
# to states via the * operator
julia> â₂ * k
Ket{KroneckerDelta,3,Float64} with 10 state(s):
  1.7320508075688772 | 3,2,3 ⟩
  3.0 | 9,8,9 ⟩
  2.23606797749979 | 5,4,5 ⟩
  2.449489742783178 | 6,5,6 ⟩
  3.1622776601683795 | 10,9,10 ⟩
  ⁞
```

We can represent this operator in a basis using the `@repr_op` macro:

```julia
julia> basis_labels = [(i,j,k) for i=1:10, j=1:10, k=1:10];

# using a different name, "a2_rep", for the representation
julia> @repr_op " a2_rep | x, y, z > = â₂ * | x, y, z > " basis_labels
OpSum{KroneckerDelta,3,Float64} with 1000 operator(s):
  3.0 | 5,8,7 ⟩⟨ 5,9,7 |
  3.0 | 8,8,7 ⟩⟨ 8,9,7 |
  1.4142135623730951 | 7,1,2 ⟩⟨ 7,2,2 |
  2.0 | 2,3,8 ⟩⟨ 2,4,8 |
  2.8284271247461903 | 4,7,6 ⟩⟨ 4,8,6 |
  2.8284271247461903 | 4,7,4 ⟩⟨ 4,8,4 |
  3.0 | 9,8,2 ⟩⟨ 9,9,2 |
  1.0 | 5,0,4 ⟩⟨ 5,1,4 |
  2.8284271247461903 | 8,7,4 ⟩⟨ 8,8,4 |
  1.4142135623730951 | 9,1,3 ⟩⟨ 9,2,3 |
  ⁞
```

#### `d" ... "` syntax for natural Dirac notation input

```julia
julia> d" < 0,0 | *  (| 0,0 > + | 1,1 >)/√2 "
0.7071067811865475

julia> default_inner(UndefinedInner())
INFO: QuDirac's default inner product type is currently UndefinedInner()

julia> d" < 0,0 | *  (| 0,0 > + | 1,1 >)/√2 "
((⟨ 0,0 | 0,0 ⟩ + ⟨ 0,0 | 1,1 ⟩) / 1.4142135623730951)
```

Multi-line support:

```julia
julia> d"""
       ψ = 1/√2 * (| :↑,:↑ > + | :↓,:↓ >)
       a = purity(ptrace(ψ*ψ', 2))
       ϕ = normalize!( 1/5 * < :↑ | + 4/5 * < :↓ | )
       result = normalize!(a * act_on(ϕ, ψ, 2))
       """

julia> result
Ket{KroneckerDelta,1,Float64} with 2 state(s):
  0.9701425001453319 | :↓ ⟩
  0.24253562503633297 | :↑ ⟩
```

#### ...and other stuff (examples and documentation coming soon)

- `xsubspace` allows easy selection of excitation subspaces of states and operators
- `permute` and `switch` allows generic permutation of factor labels for states
- `filter`/`filter!` are supported on both the labels and coefficients of operators/states
- Arbitrary mapping functions (`map`/`maplabels`/`mapcoeffs`) are also provided for applying functions to labels and coefficients
