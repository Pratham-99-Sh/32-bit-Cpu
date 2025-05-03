`include "/workspaces/32-bit-Cpu/src/Decoder.v"
`include "/workspaces/32-bit-Cpu/src/conditionalLogic.v"

module controller(input clk, reset,
                  input [31:12] Instr,
                  input [3:0] ALUFlags,
                  output [1:0] RegSrc,
                  output RegWrite,
                  output [1:0] ImmSrc,
                  output ALUSrc,
                  output [1:0] ALUControl,
                  output MemWrite, MemtoReg,
                  output PCSrc);

  // internal wire
  wire [1:0] FlagW;
  wire PCS, RegW, MemW;

  // integrate decoder (PC logic + main decode + ALU decoder)
  decoder dec(Instr[27:26], Instr[25:20], Instr[15:12],
              FlagW, PCS, RegW, MemW,
              MemtoReg, ALUSrc, ImmSrc, RegSrc, ALUControl);

  // integrate cond logic block
  condlogic cl(clk, reset, Instr[31:28], ALUFlags,
               FlagW, PCS, RegW, MemW,
               PCSrc, RegWrite, MemWrite);
endmodule
