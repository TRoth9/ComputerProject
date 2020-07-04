module ADDR_REG	(
	output [3:0]	MAR_OUT,
	input  [3:0]	MAR_IN,
	input 			WE,
	input 	 		PRGM,
	input 	 		CLK,
	input 			RESET
);

reg [3:0] MAR_DATA;

assign MAR_OUT = MAR_DATA;

always @(posedge CLK or posedge RESET) begin
	if 		(RESET) 			MAR_DATA = 4'b0000;
	else if 	(WE || PRGM) 	MAR_DATA = MAR_IN;
end
endmodule