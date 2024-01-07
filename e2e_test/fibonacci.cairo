// Copyright 2023 StarkWare Industries Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.starkware.co/open-source-license/
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions
// and limitations under the License.

%builtins output pedersen range_check bitwise
func main(
    output_ptr: felt*, pedersen_ptr: felt*, range_check_ptr: felt*, bitwise_ptr: felt*) -> (
           output_ptr: felt*, pedersen_ptr: felt*, range_check_ptr: felt*, bitwise_ptr: felt*
        ) {
    alloc_locals;

    // Load fibonacci_claim_index and copy it to the output segment.
    local a;
    local b;
    local n;
    %{ ids.a = program_input['a'] %}
    %{ ids.b = program_input['b'] %}
    %{ ids.n = program_input['n'] %}

    let (first_element, second_element) = fib(a, b, n);

    assert output_ptr[0] = n;
    assert output_ptr[1] = first_element;
    assert output_ptr[2] = second_element;

    // Return the updated output_ptr.
    return (
        output_ptr=&output_ptr[3], pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, bitwise_ptr=bitwise_ptr
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