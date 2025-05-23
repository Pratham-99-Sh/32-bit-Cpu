`include "/workspaces/32-bit-Cpu/src/CPU.v"
`include "/workspaces/32-bit-Cpu/src/inst_memory.v"
`include "/workspaces/32-bit-Cpu/src/data_memory.v"

module top(input clk, reset);

// internal wires
wire [31:0] PC, Instr, ReadData;
wire [31:0] WriteData, DataAdr;
wire MemWrite;

// instantiate cpu and memories
cpu cpu(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);
imem imem(PC, Instr);
dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);

endmodule
