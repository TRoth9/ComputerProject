module Accumulator	(output reg [7:0]Acc_out,
							 input wire [7:0]Acc_in,
							 input wire OE,WE,load,
							 input wire CLK,RESET);
		
		reg [7:0]Acc;
		
		always @(posedge CLK or posedge RESET) begin
				if (RESET) begin
					Acc <= 8'b00000000;
					Acc_out <= 8'b00000000;
				end					
				else if (WE || load) begin
					Acc <= Acc_in;					// read from bus, or programmer
				end
				else if (OE) begin
					Acc_out <= Acc;				// write to bus
				end
		end

endmodule