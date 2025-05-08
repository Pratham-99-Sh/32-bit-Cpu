module ALU (
    input  [31:0] SrcA,          // 32-bit input A
    input  [31:0] SrcB,          // 32-bit input B
    input  [1:0]  ALUControl,    // ALU control signal to select operation
    output reg [31:0] ALUResult, // 32-bit result
    output Negative,           // Negative flag
    output Zero,               // Zero flag
    output reg Carry,          // Carry flag
    output reg Overflow        // Overflow flag
);
    always @(*) begin
        case (ALUControl)
            2'b10: begin // AND operation
                ALUResult = SrcA & SrcB;
                Carry = 0;
                Overflow = 0;
            end
            2'b11: begin // OR operation
                ALUResult = SrcA | SrcB;
                Carry = 0;
                Overflow = 0;
            end
            2'b00: begin // ADD operation
                {Carry, ALUResult} = SrcA + SrcB; // Concatenation to include carry out
                //Overflow = Carry;  // True only for unsigned overflow as if result can't fit in 32bits i.e. ALUResult then carry will have overflow bit thus indicating overflow occured
                //wont work for signed numbers as they wrap around because 32nd bit is signed bit so we have to check if positive number suddenly become most negative possible in given number of bits or vice versa to detect overflow
                Overflow = (~SrcA[31] & ~SrcB[31] & ALUResult[31]) | (SrcA[31] & SrcB[31] & ~ALUResult[31]);
            end
            2'b01: begin // SUB operation
                {Carry, ALUResult} = SrcA - SrcB;
                //Overflow = Carry; //same as before
                Overflow = (SrcA[31] & ~SrcB[31] & ~ALUResult[31]) | (~SrcA[31] & SrcB[31] & ALUResult[31]);
            end
            default: begin
                ALUResult = 32'b0;
                Carry = 0;
                Overflow = 0;
            end
        endcase
    end

    assign Zero = (ALUResult == 32'b0) ? 1'b1 : 1'b0;  // Zero flag: 1 if Result is zero
    assign Negative = ALUResult[31];  // works if signed number


endmodule