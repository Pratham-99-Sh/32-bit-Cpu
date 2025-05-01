`include "CPU.v"
`include "inst_memory.v"
`include "data_memory.v"

module top(input clk, reset);

// internal wires
wire [31:0] PC, Instr, ReadData;
wire [31:0] WriteData, DataAdr;
wire MemWrite;

// instantiate cpu and memories
CPU cpu(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);
inst_memory imem(PC, Instr);
data_memory dmem(clk, MemWrite, DataAdr, WriteData, ReadData);

endmodule
