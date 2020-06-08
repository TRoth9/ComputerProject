module ProgramCounter	(output reg [3:0]counter,
								 output reg [3:0]PC_out,
								 output wire on,
								 input wire [3:0]in,
								 input wire CLK,RESET,en,
								 input wire OE,WE);
	reg [3:0]count;						 
	assign on = en;
	
	always @(OE or WE) begin
		if (OE) begin
			counter <= count;
		end
	end
	
	always @(posedge CLK or posedge RESET or posedge WE) begin
		if (RESET) 		count <= 0;
		else if (WE) count <= in;
		else if (en)	count <= count+1;
	end
endmodule