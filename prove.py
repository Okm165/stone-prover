import subprocess
from colorama import Fore, Style

def log_and_run(commands, description, cwd=None):
    full_command = " && ".join(commands)
    try:
        print(f"{Fore.YELLOW}Starting: {description}...{Style.RESET_ALL}")
        print(f"{Fore.CYAN}Command: {full_command}{Style.RESET_ALL}")
        result = subprocess.run(full_command, shell=True, check=True, cwd=cwd, text=True)
        print(f"{Fore.GREEN}Success: {description} completed!\n{Style.RESET_ALL}")
    except subprocess.CalledProcessError as e:
        print(f"{Fore.RED}Error running command '{full_command}': {e}\n{Style.RESET_ALL}")

log_and_run([
    "cairo-compile program.cairo --output program_compiled.json --proof_mode", 
], "Compiling program", cwd="e2e_test")

log_and_run([
    "cairo-run \
    --program=program_compiled.json \
    --layout=plain \
    --air_public_input=program_public_input.json \
    --air_private_input=program_private_input.json \
    --trace_file=program_trace.bin \
    --memory_file=program_memory.bin \
    --print_output \
    --proof_mode", 
], "Running program program", cwd="e2e_test")

log_and_run([
    "../cpu_air_prover \
    --out_file=../program_proof.json \
    --private_input_file=program_private_input.json \
    --public_input_file=program_public_input.json \
    --prover_config_file=cpu_air_prover_config.json \
    --parameter_file=cpu_air_params.json \
    -generate_annotations", 
], "Proving program program", cwd="e2e_test")