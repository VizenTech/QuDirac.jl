@assert (3-im) * simpk' ==  (3-im) * ((1-3im) * bra(1))
@assert (3-im) * simpk' == ((3+im)*(1+3im)*ket(1))'
@assert (-im * projop')[1,1] == 0-10im

@assert length(filter((k,v) -> ktlabel(k)==[3], op')) == 3
@assert b'*b'*b' == (b^3)'
@assert (op'*op') == (op*op)'
@assert maplabels(reverse, mapcoeffs(ctranspose, op)) == op'
@assert op[2,1] == 8-4im
@assert (k*k)*(b*b) == tensor(k*b,k*b)
@assert op+op == 2 * op
@assert op-op == 0 * op
@assert op-op+op == op
@assert filternz!(xsubspace(tensor(op,op,op),3)) == (16 - 88im) * ket(1,1,1) * bra(1,1,1) 

@test_approx_eq norm(qubits) 1
@assert ptrace(belldens, 1) == ptrace(belldens, 2)
