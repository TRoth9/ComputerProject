module ProgramCounter	(output [3:0]counter,
								 output reg [3:0]PC_out,
								 output wire on,
								 input wire[3:0]PC_in,
								 input wire CLK,RESET,en,
								 input wire OE,WE,load);
	reg [3:0]count;						 
	assign on = en;
	assign counter = count;	// So we can always see what instruction we are on
		
	always @(posedge CLK) begin
		if (RESET) 			count <= 4'b0000;
		else if (en) begin
			count <= count+1;	// Counting
			
			if (WE || load)	count	<=	PC_in;	// read from bus,load from programmer
			else if (OE)		PC_out <= count;	// output to bus
		end
	end
endmodule