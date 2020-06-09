module Accumulator	(output reg [7:0]Acc_out,
							 input wire [7:0]Acc_in,
							 input wire OE,WE,load,
							 input wire CLK,RESET);
		
		reg [7:0]Acc;
		
		always @(posedge CLK) begin
				if (RESET) begin
					Acc <= 8'b00000000;
					Acc_out <= 8'b00000000;
				end					
				else if (load) Acc <= Acc_in;	// load from programmer
				
				if (WE & ~load) begin
					Acc <= Acc_in;					// read from bus, not loading
				end
				else if (OE) begin
					Acc_out <= Acc;				// write to bus
				end
		end

endmodule