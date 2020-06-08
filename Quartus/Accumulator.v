module Accumulator	(output reg [7:0] Acc_out,
							 input wire [7:0] Bus_in,
							 input wire OE,
							 input wire WE,
							 input wire CLK,
							 input wire RESET);
		
		reg [7:0] Acc;
		
		always @(Acc_out or OE or WE) begin
			if (!OE) begin
				Acc_out <= 8'b00000000;
			end
		end
		
		always @(posedge CLK or posedge RESET) begin
				if (RESET) begin
					Acc <= 8'b00000000;
					Acc_out <= 8'b00000000;
				end					
				else if (WE) begin
					Acc <= Bus_in;		//read from bus
				end
				else if (OE) begin
					Acc_out <= Acc;	//write to bus
				end
		end

endmodule