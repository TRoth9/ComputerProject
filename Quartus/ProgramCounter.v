module ProgramCounter	(
	output		[3:0] COUNT,
	output 				ON,
	input 		[3:0]	PC_IN,
	input 				PRGM,
	input 				RESET,
	input 				EN,
	input 				CLK
);
								 
reg [3:0] COUNTER;

assign COUNT = COUNTER;
assign ON = EN;

always @(posedge CLK or posedge RESET)
begin
	if (RESET)
		COUNTER = 4'b0000;
	else if (PRGM)	
		COUNTER = PC_IN;
	else if (EN) 			
		COUNTER = COUNTER + 4'd1;	// Counting
end

endmodule