module decoder(input [1:0] Op,
               input [5:0] Funct,
               input [3:0] Rd,
               output reg [1:0] FlagW,
               output PCS, RegW, MemW,
               output MemtoReg, ALUSrc,
               output [1:0] ImmSrc, RegSrc, output reg [1:0] ALUControl);

    // internal wires
    wire Branch, ALUOp;
    reg [9:0] controls;

    // Main Decoder
    always @(*)
        begin
            casez({Op, Funct[5], Funct[0]})
            // here i replaced x with 0 as x is not synthsizable
            // even if synthesis tool could replace it with 0 or 1 which ever optimal instead i replaced with 0 as signals off.
                4'b000?: controls = 10'b0000001001; //10'b0000xx1001;   //DP Reg
                4'b001?: controls = 10'b0001001001; //10'b0001001x01;   //DPImm  [i turned 3rd bit from msb to 0 instead of 1 because dataprocessing type of instructions should not write to memroy unlike shown in table.]
                4'b01?0: controls = 10'b0011010100; //10'b0x11010100;   //STR
                4'b01?1: controls = 10'b0101011000; //10'b0101011x00;   //LDR
                4'b10??: controls = 10'b1001100010; //10'b1001100x10;   //B
                default: controls = 10'b0000000000; //10'bxxxxxxxxxx;   //InstType
            endcase
        end

    assign {Branch, MemtoReg, MemW, ALUSrc, ImmSrc, RegW, RegSrc, ALUOp} = controls;


    // ALU Decoder
    always @(*) begin
        if (ALUOp) begin // which DP Instr?
            case (Funct[4:1])
                4'b0100: ALUControl = 2'b00; // ADD
                4'b0010: ALUControl = 2'b01; // SUB
                4'b0000: ALUControl = 2'b10; // AND
                4'b1100: ALUControl = 2'b11; // ORR
                default: ALUControl = 2'bxx; // unimplemented
            endcase

            // update flags if 5th bit is set (C & V only for arithmetic operations)
            FlagW[1] = Funct[0];
            FlagW[0] = Funct[0] & (ALUControl == 2'b00 || ALUControl == 2'b01);
        end else begin
            ALUControl = 2'b00;         // default to ADD for non-DP instructions
            FlagW     = 2'b00;          // don't update flags
        end
    end

    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
    //Here even if we just write to r15 it will not change pc but we still want to update our pc to that new instruction address
    //therefore we will keep our PCS high so that PC will get the same signal (result) that regfile writeData port will get.
endmodule
