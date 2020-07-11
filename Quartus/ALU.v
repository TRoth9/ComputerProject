module ALU_REG	(
	output signed 		[7:0]	ALU_OUT,	// Output to bus
	input  signed		[7:0]	ACC_IN,	// Accumulator input
	input  signed		[7:0]	BREG_IN,	// B register input
	input  wire			[2:0]	OP,		// Op code
	input  wire				CLK			// clock
);			
	
reg [7:0]ALU_DATA;

parameter ADD = 3'b000,	// Addition
			 SUB = 3'b001,	// Subtraction
			 DEC = 3'b010,	// Decrement
			 INC = 3'b011,	// Increment
			 OC  = 3'b100,	// One's Complement
			 BND = 3'b101,	// Bitwise AND
			 BOR = 3'b110,	// Bitwise OR
			 BXR = 3'b111;	// Bitwise XOR
			 
assign ALU_OUT = ALU_DATA;

always @(posedge CLK) 
begin
	case (OP)
		ADD	:	ALU_DATA <= ACC_IN + BREG_IN;
		SUB	:	ALU_DATA <= ACC_IN - BREG_IN;
		DEC	:	ALU_DATA <= ACC_IN - 8'd1;
		INC	:	ALU_DATA <= ACC_IN + 8'd1;
		OC		:	ALU_DATA <= ~ACC_IN;
		BND	:	ALU_DATA <= ACC_IN & BREG_IN;
		BOR	:	ALU_DATA <= ACC_IN | BREG_IN;
		BXR	:	ALU_DATA <= ACC_IN ^ BREG_IN;
	endcase
end
endmodule