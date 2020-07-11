module Accumulator	(
	output	[7:0] ACC_OUT,
	input		[7:0]	ACC_IN,
	input				WE,PRGM,RESET,
	input 			CLK
);
		
reg [7:0] ACC_DATA;

assign ACC_OUT = ACC_DATA;

always @(posedge CLK or posedge RESET) begin
		if (RESET) begin
			ACC_DATA = 8'b00000000;
		end					
		else if (WE || PRGM) begin
			ACC_DATA = ACC_IN;					// read from bus, or programmer
		end
end

endmodule