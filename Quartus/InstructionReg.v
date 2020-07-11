module InstructionReg	(
	output		[3:0] INST_OUT,
	output		[3:0] ADDR_OUT,	
	input			[3:0] ADDR_IN,		// Address for EEPROM
	input			[3:0] INST,			// Instruction
	input					WE,
	input					PRGM,
	input 				CLK,
	input					RESET
);

reg [7:0] IR_DATA;	
			
assign INST_OUT = IR_DATA[7:4];
assign ADDR_OUT = IR_DATA[3:0];

always @(posedge CLK or posedge RESET) begin
	if (RESET)
		IR_DATA <= 8'b0;
	else if (WE || PRGM) 
		IR_DATA <= {INST,ADDR_IN};
end

endmodule