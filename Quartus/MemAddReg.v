module MemAddReg	(output reg [3:0]MAR_out,
						 input wire [3:0]MAR_in,
						 input wire WE,load,
						 input wire CLK,RESET);
	
	always @(posedge CLK or posedge RESET) begin
		if 		(RESET) 			MAR_out = 4'b0000;
		else if 	(WE || load) 	MAR_out = MAR_in;
	end
endmodule