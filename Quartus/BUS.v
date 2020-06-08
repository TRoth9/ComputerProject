module BUS	(output reg [7:0] Bus_out,
				 input wire [7:0] Bus_in,
				 input wire OE,WE);

	reg [7:0] Bus_data;

	always @(OE or WE) begin
		if (WE) begin
			Bus_data <= Bus_in;		//write to bus
			Bus_out <= 8'b00000000;
		end else if (OE) begin		//read from bus
			Bus_out <= Bus_data;
		end
	end
endmodule