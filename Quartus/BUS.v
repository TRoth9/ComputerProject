module BUS	(
	output reg	[7:0] Bus_out,
	input			[7:0] Bus_in,
	input			CLK,
	input			RESET
);				 

always @(posedge CLK or posedge RESET)
begin
	if (RESET)
		Bus_out <= 8'b0;
	else
		Bus_out <= Bus_in;
end

endmodule