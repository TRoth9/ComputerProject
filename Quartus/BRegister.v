module BRegister	(output		[7:0]Breg_out,
						 input wire [7:0]Breg_in,
						 input wire OE,WE,load,
						 input wire CLK,RESET);
		
		reg [7:0]Breg_data;
		
		assign Breg_out = Breg_data;
		
		always @(posedge CLK or posedge RESET) begin
				if (RESET) begin
					Breg_data = 8'b00000000;
				end					
				else if (WE || load) begin
					Breg_data = Breg_in;					// read from bus or loading
				end
		end

endmodule