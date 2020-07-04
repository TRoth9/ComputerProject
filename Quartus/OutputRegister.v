module OP_REG	(
	output	[7:0] OP_OUT,
	input 	[7:0] OP_IN,
	input				WE,PRGM,
	input 			CLK,RESET);
		
	reg [7:0] OP_DATA;
	
	assign OP_OUT = OP_DATA;
	
	always @(posedge CLK or posedge RESET) begin
			if (RESET) begin
				OP_DATA = 8'b00000000;
			end					
			else if (WE || PRGM) begin
				OP_DATA = OP_IN;					// read from bus or loading
			end
	end

endmodule