module ALU_REG	(
		output signed	[7:0]	ALU_out,
		input  signed	[7:0]	Acc_in,		// Accumulator input
		input  signed	[7:0]	Breg_in,		// B register input
		input  wire		[2:0]	OP,			// Op code
		input  wire				OE,			// output enable
		input  wire				CLK			// clock
	);			
	
	reg [7:0]ALU_data;
	
	parameter ADD = 3'b000,	// Addition
				 SUB = 3'b001,	// Subtraction
				 DEC = 3'b010,	// Decrement
				 INC = 3'b011,	// Increment
				 OC  = 3'b100,	// One's Complement
				 BND = 3'b101,	// Bitwise AND
				 BOR = 3'b110,	// Bitwise OR
				 BXR = 3'b111;	// Bitwise XOR
		
	always @(ALU_data or SUB) 
	begin
		if (OE) ALU_out <= ALU_data;			// output to bus
	end
	
	always @(posedge CLK) 
	begin
		case (OP)
			ADD	:	ALU_data <= Acc_in + Breg_in;
			SUB	:	ALU_data <= Acc_in - Breg_in;
			DEC	:	ALU_data <= Acc_in - 1;
			INC	:	ALU_data <= Acc_in + 1;
			OC		:	ALU_data <= ~Acc_in;
			BND	:	ALU_data <= Acc_in & Breg_in;
			BOR	:	ALU_data <= Acc_in | Breg_in;
			BXR	:	ALU_data <= Acc_in ^ Breg_in;
		endcase
	end
endmodule