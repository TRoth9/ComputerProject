module ProgramCounter	(output reg [3:0]counter,
								 output wire on,
								 input wire [3:0]in,
								 input wire CLK,RESET,load,en);
								 
	assign on = en;
	
	always @(posedge CLK or posedge RESET or posedge load) begin
		if (RESET) 		counter <= 0;
		else if (load) counter <= in;
		else if (en)	counter <= counter+1;
	end
endmodule