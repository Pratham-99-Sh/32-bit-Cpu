module imem(input [31:0] a,
            output [31:0] rd);
  reg [31:0] RAM[63:0];
  initial
    $readmemh("/workspaces/32-bit-Cpu/src/memfile.dat", RAM);
  assign rd = RAM[a[31:2]]; // word aligned
endmodule
