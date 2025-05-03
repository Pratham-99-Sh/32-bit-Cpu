module imem(input [31:0] a,
            output [31:0] rd);
  reg [31:0] RAM[63:0];
  initial
    $readmemh("/workspaces/32-bit-Cpu/src/memfile.dat", RAM, 0, 22);  //since we know our code is of 23 instructions to avoid warning that we get from executing line below commented
    //$readmemh("/workspaces/32-bit-Cpu/src/memfile.dat", RAM); // here since our file doesn't fill all 64 positions and ends way before it we see a warning.
  assign rd = RAM[a[31:2]]; // word aligned
endmodule