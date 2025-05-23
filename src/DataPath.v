`include "/workspaces/32-bit-Cpu/src/mux2.v"
`include "/workspaces/32-bit-Cpu/src/flop.v"
`include "/workspaces/32-bit-Cpu/src/adder.v"
`include "/workspaces/32-bit-Cpu/src/regfile.v"
`include "/workspaces/32-bit-Cpu/src/extend.v"
`include "/workspaces/32-bit-Cpu/src/alu.v"

module datapath(input clk, reset,
    input [1:0] RegSrc,
    input RegWrite,
    input [1:0] ImmSrc,
    input ALUSrc,
    input [1:0] ALUControl,
    input MemtoReg,
    input PCSrc,
    output [3:0] ALUFlags,
    output [31:0] PC,
    input [31:0] Instr,
    output [31:0] ALUResult, WriteData,
    input [31:0] ReadData);

    wire [31:0] PCNext, PCPlus4, PCPlus8;
    wire [31:0] ExtImm, SrcA, SrcB, Result;
    wire [3:0]  RA1, RA2;

    // PC logic
    mux2 #(.WIDTH(32)) pcmux( .y(PCNext), .d0(PCPlus4), .d1(Result), .s(PCSrc) );
    flop #(.WIDTH(32)) pcreg(clk, reset, PCNext, PC);
    adder #(.WIDTH(32)) pcadd1(PC, 32'b100, PCPlus4);
    adder #(.WIDTH(32)) pcadd2(PCPlus4, 32'b100, PCPlus8);

    // register file logic
    mux2 #(.WIDTH(4)) ralmux(Instr[19:16], 4'b1111, RegSrc[0], RA1);
    mux2 #(.WIDTH(4)) ra2mux(Instr[3:0], Instr[15:12], RegSrc[1], RA2);
    regfile rf(clk, RegWrite, RA1, RA2, Instr[15:12], Result, PCPlus8, SrcA, WriteData);
    mux2 #(.WIDTH(32)) resmux(ALUResult, ReadData, MemtoReg, Result);
    extend ext(Instr[23:0], ImmSrc, ExtImm);

    // ALU logic
    mux2 #(.WIDTH(32)) srcbmux(WriteData, ExtImm, ALUSrc, SrcB);
    ALU alu(SrcA, SrcB, ALUControl, ALUResult, ALUFlags[3], ALUFlags[2], ALUFlags[1], ALUFlags[0]);

endmodule