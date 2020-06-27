module BRegister	(
	output	[7:0] BREG_OUT,
	input 	[7:0] BREG_IN,
	input				WE,PRGM,
	input 			CLK,RESET);
		
	reg [7:0]BREG_DATA;
	
	assign BREG_OUT = BREG_DATA;
	
	always @(posedge CLK or posedge RESET) begin
			if (RESET) begin
				BREG_DATA = 8'b00000000;
			end					
			else if (WE || PRGM) begin
				BREG_DATA = BREG_IN;					// read from bus or loading
			end
	end

endmodule