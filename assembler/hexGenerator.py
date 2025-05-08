# run_assembler.py
from assembler import assemble, save_hex

File_Name = input("Enter the name of assembly code file (assemblyCodes/<?>): ")

with open(f"/workspaces/32-bit-Cpu/assembler/assemblyCodes/{File_Name}", "r") as f:
    source_code = f.read()
print(source_code)

machine_code = assemble(source_code)
print(machine_code)
save_hex(machine_code, "/workspaces/32-bit-Cpu/assembler/program.mem")
print("Assembled successfully into program.mem")
