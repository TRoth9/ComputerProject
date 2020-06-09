module BUS	(output reg [7:0] Bus_out,
				 input wire [7:0] Bus_in,
				 input wire OE,WE);

	reg [7:0] Bus_data;

	always @(OE or WE) begin
		if (WE) begin
			Bus_data <= Bus_in;		// Read module data
			Bus_out <= Bus_data;		//	write from module to bus
		end else if (OE) begin		
			Bus_out <= Bus_data;		//	Display bus values in output
		end
	end
endmodule