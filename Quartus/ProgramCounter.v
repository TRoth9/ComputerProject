module ProgramCounter	(output reg [3:0]counter,
								 output reg [3:0]PC_out,
								 output wire on,
								 input wire[3:0]PC_in,
								 input wire CLK,RESET,en,
								 input wire OE,WE,load);
	reg [3:0]count;						 
	assign on = en;
	
	always @(posedge CLK) begin
		if (en)				count <= count+1;	// Counting

		if (RESET) 			count <= 4'b0000;
		else if (WE)		count	<=	PC_in;	// read from bus, not loading
		else if (OE)		PC_out <= count;	// output to bus
		else if (load)		count <= PC_in;	// load from programmer
	end
endmodule