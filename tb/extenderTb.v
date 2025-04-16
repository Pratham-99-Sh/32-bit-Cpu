// Verilog is compiled in the order you pass files to iverilog. So you don’t need to \includesource files inside the testbench.
// `include "/workspaces/32-bit-Cpu/src/extend.v"

module testBench;

    reg [23:0]Instr;
    reg [1:0]ImmSrc;
    wire [31:0]ExtImm;

    extend e1(.Instr(Instr), .ImmSrc(ImmSrc), .ExtImm(ExtImm));

    initial #300 $finish;

    initial begin
        Instr = 24'h000009;
        #16 ImmSrc = 2'b00;
        #10 ImmSrc = 2'b01;
        #10 ImmSrc = 2'b10;
    end

    initial begin
        $monitor($time, "\t%b\t%b\t%b", Instr, ImmSrc, ExtImm);
        $dumpfile("/workspaces/32-bit-Cpu/sim/results/extendDump.vcd");
        $dumpvars(0, testBench);
    end

endmodule