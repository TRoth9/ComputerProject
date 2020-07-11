`timescale 1ns			/100ps
module InstructionReg_tb();
	wire	[3:0] INST_OUT;
	wire	[3:0] ADDR_OUT;	
	reg	[3:0] ADDR_IN;	// Address for EEPROM
	reg	[3:0] INST;	// Instruction
	reg			WE;
	reg			PRGM;
	reg 			CLK;
	reg			RESET;
	
InstructionReg	uut(
	.INST_OUT	( INST_OUT	),
	.ADDR_OUT	( ADDR_OUT	),	
	.ADDR_IN		( ADDR_IN	),		// Address for EEPROM
	.INST			( INST		),			// Instruction
	.WE			( WE			),
	.PRGM			( PRGM		),
	.CLK			( CLK	 		),
	.RESET		( RESET		)
);
initial begin	
	ADDR_IN = 1'b0;		// Address for EEPROM
	INST = 1'b0;			// Instruction
	WE = 1'b0;
	PRGM = 1'b0;
	CLK = 1'b0;
	RESET = 1'b1;
	#25;
	
	RESET = 0;
	ADDR_IN = 4'b1010;
	INST = 4'b1100;
	PRGM = 1'b1;
	#50;
	
	PRGM = 1'b0;
	#50
	
	ADDR_IN = 4'b0011;
	INST = 4'b1010;
	WE = 1'b1;
	#50;
	
	WE = 1'b0;
end

always begin
	#50;
	CLK = ~CLK;
end

endmodule