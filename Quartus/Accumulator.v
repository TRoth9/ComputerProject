module Accumulator	(output		[7:0]Acc_out,
							 input wire [7:0]Acc_in,
							 input wire OE,WE,load,
							 input wire CLK,RESET);
		
		reg [7:0]Acc_data;
		
		assign Acc_out = Acc_data;
		
		always @(posedge CLK or posedge RESET) begin
				if (RESET) begin
					Acc_data = 8'b00000000;
				end					
				else if (WE || load) begin
					Acc_data = Acc_in;					// read from bus, or programmer
				end
				
		end

endmodule