# Overview

[STARK](https://starkware.co/stark/) is a proof system. It uses cutting-edge cryptography to
provide poly-logarithmic verification resources and proof size, with minimal and
post-quantum-secure assumptions.

This repository contains a prover and a verifier for STARKs, and in particular for the CPU AIR
underlying the CairoZero programming language.

# Installation instructions

## Building using the dockerfile

The root directory contains a dedicated Dockerfile which automatically builds the package and
runs the unit tests on a simulated machine.
You should have docker installed (see https://docs.docker.com/get-docker/).

Clone the repository:

```bash
git clone https://github.com/starkware-libs/stone-prover.git
```

Build the docker image:

```bash
cd stone-prover
docker build --tag prover .
```

This will run an end-to-end test with an example cairo program.
Once the docker image is built, you can fetch the prover and verifier executables using:

```bash
container_id=$(docker create prover)
docker cp -L ${container_id}:/bin/cpu_air_prover ./e2e_test
docker cp -L ${container_id}:/bin/cpu_air_verifier ./e2e_test
```

## Creating and verifying a proof of a CairoZero program

To run and prove the example program `fibonacci.cairo`,
install `cairo-lang` version 0.12.0 (see further instructions in the
[cairo-lang repository](https://github.com/starkware-libs/cairo-lang/tree/v0.12.0)):

```bash
pip install cairo-lang==0.12.0
```

Navigate to the example test directory (`e2e_test`):

```bash
cd e2e_test
```

Compile `fibonacci.cairo`:

```bash
cairo-compile fibonacci.cairo --output fibonacci_compiled.json --proof_mode
```

Run the compiled program to generate the prover input files:

```bash
cairo-run \
    --program=fibonacci_compiled.json \
    --layout=starknet_with_keccak \
    --program_input=fibonacci_input.json \
    --air_public_input=fibonacci_public_input.json \
    --air_private_input=fibonacci_private_input.json \
    --trace_file=fibonacci_trace.json \
    --memory_file=fibonacci_memory.json \
    --print_output \
    --proof_mode
```

Run the prover:
```bash
./cpu_air_prover \
    --out_file=fibonacci_proof.json \
    --private_input_file=fibonacci_private_input.json \
    --public_input_file=fibonacci_public_input.json \
    --prover_config_file=cpu_air_prover_config.json \
    --parameter_file=cpu_air_params.json \
    -generate_annotations
```

The proof is now available in the file `fibonacci_proof.json`.

Finally, run the verifier to verify the proof:
```bash
cpu_air_verifier --in_file=fibonacci_proof.json && echo "Successfully verified example proof."
```

**Note**: The verifier only checks that the proof is consistent with
the public input section that appears in the proof file.
The public input section itself is not checked.
For example, the verifier does not check what CairoZero program is being proved,
or that the builtins memory segments are of valid size.
These things need to be checked externally.

## Configuration for other input sizes

The number of steps affects the size of the trace.
Such changes may require modification of `cpu_air_params.json`.
Specifically, the following equation must be satisfied.
```
log₂(last_layer_degree_bound) + ∑fri_step_list = log₂(#steps) + 4
```
For instance, assuming a fixed `last_layer_degree_bound`,
a larger number of steps requires changes to the `fri_step_list`
to maintain the equality.

FRI steps should typically be in the range 2-4;
the degree bound should be in the range 4-7.

The constant 4 that appears in the equation is hardcoded `log₂(trace_rows_per_step) = log₂(16) = 4`.

## For Mac users

To build the docker, run:

```bash
docker build --tag prover . --build-arg CMAKE_ARGS=-DNO_AVX=1
```

To freely use the `cairo-run`, `cpu_air_prover`, and `cpu_air_verifier` commands,
work inside the docker using:

```bash
docker run -it prover bash
```
