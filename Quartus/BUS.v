module BUS	(output reg	[7:0] Bus_out,
				 input wire [7:0] Bus_in,
				 input wire CLK,RESET);				 
	
//	assign Bus_out =	(RESET)? 8'b0 : 8'hA0;
	
	always @(posedge CLK or posedge RESET)
	begin
		if (RESET)
			Bus_out <= 8'b0;
		else
			Bus_out <= Bus_in;
	end
endmodule