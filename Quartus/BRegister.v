module BRegister	(output reg [7:0]Breg_out,
							 input wire [7:0]Breg_in,
							 input wire OE,WE,load,
							 input wire CLK,RESET);
		
		reg [7:0]Breg;
		
		always @(posedge CLK) begin
				if (RESET) begin
					Breg <= 8'b00000000;
					Breg_out <= 8'b00000000;
				end					
				else if (load) Breg <= Breg_in;	// load from programmer
				
				if (WE & ~load) begin
					Breg <= Breg_in;					// read from bus, not loading
				end
				else if (OE) begin
					Breg_out <= Breg;				// write to bus
				end
		end

endmodule