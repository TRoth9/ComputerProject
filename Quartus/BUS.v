module BUS	(output reg [7:0] Bus_out,
				 input wire [7:0] Bus_in,
				 input wire CLK,RESET);				 
	
	always @(posedge CLK or posedge RESET) begin
		if (RESET)	Bus_out <= 8'b00000000;
		else			Bus_out <= Bus_in;		// Read from module or programmer
	end
endmodule