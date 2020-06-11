module BUS	(output [7:0] Bus_out,
				 input wire [7:0] Bus_in,
				 input wire WE);

	reg [7:0] Bus_data;

	assign Bus_out = Bus_data;
	
	always @(WE or Bus_data or Bus_in) begin
		if (WE) Bus_data <= Bus_in;		// Read from module or programmer
	end
endmodule