module Mem	(output reg [7:0]Mem_out,
				 input wire [7:0]Mem_in,
				 input wire [3:0]Address,
				 input wire OE,WE,load,
				 input wire CLK,RESET);

	reg [7:0]Memory[0:15];
				 
	always @(posedge CLK or posedge RESET) begin
		if 		(RESET) 			Memory[Address] = 8'b00000000;
		else if 	(WE || load) begin
			Memory[Address] = Mem_in;
		end
		else if 	(OE)				Mem_out = Memory[Address];
	end
endmodule