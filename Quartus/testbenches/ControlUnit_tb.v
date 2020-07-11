`timescale 1ns			/100ps
module ControlUnit_tb();

wire	PRGM_PC;
wire	PRGM_ACC;
wire	PRGM_BREG;
wire	PRGM_MAR;
wire	PRGM_EEPROM;
wire	PRGM_OR;
wire	PRGM_BUS;
wire	OE_PC;
wire	OE_ACC;
wire	OE_ALU;	
wire	OE_EEPROM;		
wire	OE_IR;
wire	WE_ACC;
wire	WE_BREG;		
wire	WE_MAR;	
wire	WE_EEPROM;	
wire	WE_OR;	
wire	WE_IR;
wire	DONE_CU;	
wire	EN_CU;
wire	CLR;
wire	[3:0] OP;
reg	[3:0]	SEL;
reg	[3:0]	INST;
reg			OE;
reg			WE;
reg			PRGM;
reg			DONE;
reg	 		CLK;
reg			RESET_CU;

	
ControlUnit	CU_1	(
	.PRGM_PC			( PRGM_PC		),
	.PRGM_ACC		( PRGM_ACC		),
	.PRGM_BREG		( PRGM_BREG		),
	.PRGM_MAR		( PRGM_MAR		),
	.PRGM_EEPROM	( PRGM_EEPROM	),
	.PRGM_OR			( PRGM_OR		),
	.PRGM_BUS		( PRGM_BUS		),
	.OE_PC			( OE_PC			),
	.OE_ACC			( OE_ACC			),
	.OE_ALU			( OE_ALU			),	
	.OE_EEPROM		( OE_EEPROM		),		
	.OE_IR			( OE_IR			),
	.WE_ACC			( WE_ACC			),
	.WE_BREG			( WE_BREG		),		
	.WE_MAR			( WE_MAR			),	
	.WE_EEPROM		( WE_EEPROM		),	
	.WE_OR			( WE_OR			),	
	.WE_IR			( WE_IR			),	
	.EN				( EN_CU			),
	.OP				( OP				),
	.SEL				( SEL				),
	.INST				( INST			),
	.PRGM				( PRGM			),
	.OE				( OE				),
	.WE				( WE				),
	.DONE				( DONE			),
	.CLK				( CLK				),
	.CLR				( RESET_CU		)
);

initial begin
	CLK = 1'b0;
	INST = 4'b0;
	RESET_CU = 1;
	PRGM = 0;
	#125;
	
	RESET_CU = 0;
	INST = 4'b0001;	// Write to Accumulator
	#275;
	
	DONE = 1'b1;
	#475;
	
	INST = 4'b1000;
end

always begin
	#50;
	CLK = ~CLK;
end

endmodule