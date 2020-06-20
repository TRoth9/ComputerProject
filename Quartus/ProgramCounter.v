module ProgramCounter	(output reg [3:0]count,
								 output reg [3:0]PC_out,
								 output wire on,
								 input wire[3:0]PC_in,
								 input wire CLK,RESET,en,
								 input wire OE,WE,load);
								 
	reg [3:0]counter;
	
	assign on = en;
	
	always @(WE or OE or load or counter or PC_in) begin
		if (WE || load)	count = PC_in;	// read from bus,load from programmer
		else 					count = counter;
		
		if (OE)	PC_out = counter;	// output to bus		
	end
	
	always @(posedge CLK or posedge RESET) begin
		if (RESET) 			counter = 4'b0000;
		else if (en) 		counter = counter+1;	// Counting
		else if (WE || load)	counter = PC_in;
		end
endmodule