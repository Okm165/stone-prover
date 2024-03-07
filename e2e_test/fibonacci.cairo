%builtins output pedersen range_check bitwise poseidon
func main(
        output_ptr: felt*,
        pedersen_ptr: felt*,
        range_check_ptr: felt,
        bitwise_ptr: felt*,
        poseidon_ptr: felt*
    ) -> (
            output_ptr: felt*,
            pedersen_ptr: felt*,
            range_check_ptr: felt,
            bitwise_ptr: felt*,
            poseidon_ptr: felt*
        ) {
    alloc_locals;

    local program_hash;
    local output_hash;
    local a;
    local b;
    local n;
    %{ 
        ids.program_hash = program_input['program_hash']
        ids.output_hash = program_input['output_hash']
        ids.a = program_input['a']
        ids.b = program_input['b']
        ids.n = program_input['n']
    %}

    if (program_hash == 0) {
        assert a = 1;
        assert b = 1;
    } else {
        //
    }

    let (c, d) = fib(a, b, n);

    assert output_ptr[0] = c;
    assert output_ptr[1] = d;
    assert output_ptr[2] = n;

    // Return the updated output_ptr.
    return (
        output_ptr=&output_ptr[3],
        pedersen_ptr=pedersen_ptr,
        range_check_ptr=range_check_ptr,
        bitwise_ptr=bitwise_ptr,
        poseidon_ptr=poseidon_ptr
    );
}

func fib(first_element: felt, second_element: felt, n: felt) -> (first_element: felt, second_element: felt) {
    if (n == 0) {
        return (first_element=first_element, second_element=second_element);
    }

    return fib(
        first_element=second_element, second_element=first_element + second_element, n=n - 1
    );
}