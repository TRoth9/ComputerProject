`timescale 1ns			/100ps
module ALU_tb();

wire 	[3:0]COUNT;
wire	[7:0]BUS_OUT;
wire	[7:0]CURRENT;
wire	ON;
reg 	[3:0]SEL; //select from 16 modules
reg 	[7:0]PRGM_IN;
reg	[2:0]OP;
reg 	CLK,RESET;
reg 	EN,GO;		//go updates regs for our selected module
reg 	OE,WE,PRGM;
reg 	HLT;	//halt the PC

	// need to fix clock delays

parameter ACC  = 4'b0001,
			 BREG = 4'b0010,
			 ALU	= 4'b0011;
	
// ALU OP Codes //
parameter ADD = 3'b000,	// Addition
			 SUB = 3'b001,	// Subtraction
			 DEC = 3'b010,	// Decrement
			 INC = 3'b011,	// Increment
			 OC  = 3'b100,	// One's Complement
			 BND = 3'b101,	// Bitwise AND
			 BOR = 3'b110,	// Bitwise OR
			 BXR = 3'b111;	// Bitwise XOR		
			 
FPGAComputer uut(
			.COUNT	( COUNT		),
			.BUS_OUT	( BUS_OUT	),
			.CURRENT	( CURRENT	),
			.ON		( ON			),
			.SEL		( SEL			),
			.PRGM_IN	( PRGM_IN	),
			.OP_PRGM	( OP			),
			.CLK		( CLK			),
			.RESET	( RESET		),
			.EN		( EN			),
			.GO		( GO			),
			.OE		( OE			),
			.WE		( WE			),
			.PRGM		( PRGM 		),
			.HLT		( HLT			)
);

initial begin
	CLK = 1'b0;
	RESET = 1'b1;
	SEL = 4'b000;
	PRGM_IN = 8'b00000000;
	EN = 1'b0;
	GO = 1'b1;
	OE = 1'b0;
	WE = 1'b0;
	PRGM = 1'b0;
	HLT = 1'b0;
	#25;
	
	RESET = 1'b0;				// reset modules
	SEL = ACC;
	GO = 1'b0;
	#50;
	
	// Program Accumulator
	PRGM_IN = 8'b10101010;
	PRGM = 1'b1;
	
	#50;
	
	#50;
	SEL = BREG;					// Program Bregister
	OE = 1'b0;
	PRGM_IN = 8'b01010101;
	
	#50;
	
	#50;
	SEL = ALU;
	OP = ADD;					// ACC + BREG
	OE = 1'b1;					// Output ALU to register
	
	
	#50;
//	OE = 1'b0;
	
	#50;
	OP = SUB;					// ACC - BREG
	
	#100;
	OE = 1'b0;
	OP = DEC;					// ACC--
	
	#100;
	OP = INC;					// ACC++
	
	#100;
	OP = OC;						// ~ACC
	
	#100;
	OP = BND;					// ACC & BREG
	
	#100;
	OP = BOR;					// ACC | BREG
	
	#100;
	OP = BXR;					// ACC ^ BREG
end

always begin
	#50;
	CLK = ~CLK;
end

endmodule