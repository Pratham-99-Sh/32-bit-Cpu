`include "/workspaces/32-bit-Cpu/src/top.v"

module testBench();
    reg clk;
    reg reset;
    //reg [31:0] WriteData, DataAdr;
    //reg MemWrite;

    // instantiate device to be tested
    top dut(clk, reset);

    // initialize test
    initial begin
        reset <= 1;
        #10 reset <= 0;
        clk <= 1;
    end

    // generate clock to sequence tests
    always #5 clk = ~clk;

    always @(dut.cpu.dp.rf.rf[2])
    begin
        $display("R1 = %d,\tR2 = %d", dut.cpu.dp.rf.rf[1], dut.cpu.dp.rf.rf[2]);
    end

    initial begin
        #10000
        $finish;
    end
endmodule