# run_assembler.py
from assembler import assemble, save_hex

with open("/workspaces/32-bit-Cpu/assembler/program.s", "r") as f:
    source_code = f.read()
print(source_code)

machine_code = assemble(source_code)
print(machine_code)
save_hex(machine_code, "/workspaces/32-bit-Cpu/assembler/program.mem")
print("Assembled successfully into program.mem")
