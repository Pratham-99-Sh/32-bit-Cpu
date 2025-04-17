module testBench;
    reg [31:0] SrcA, SrcB;
    wire [31:0]ALUResult;
    reg [1:0] ALUControl;
    wire Zero, Negative, Overflow, Carry;

    ALU A(.SrcA(SrcA), .SrcB(SrcB), .ALUControl(ALUControl), .ALUResult(ALUResult), .Zero(Zero), .Negative(Negative), .Overflow(Overflow), .Carry(Carry));

    initial #300 $finish;

    initial begin
        SrcA = 32'h00000004;
        SrcB = 32'h00000005;
        #16 ALUControl = 2'b00;
        #10 ALUControl = 2'b01;
        #10 ALUControl = 2'b10;
        #10 ALUControl = 2'b11;
    end

    initial begin
        $monitor($time, "\t%b\t%b\t%b\t%b", ALUControl, ALUResult, SrcA, SrcB);
        $dumpfile("/workspaces/32-bit-Cpu/sim/results/aluDump.vcd");
        $dumpvars(0, testBench);
    end
endmodule