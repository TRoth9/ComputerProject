`timescale 1ns			/100ps
module MAR_tb();	
	wire 		[3:0] COUNT;				// ProgramCounter
	wire		[7:0] CURRENT;				// Current module data
	wire				ON;					// Turns on PC
	wire 		[9:0]	CLK_COUNT;			// EEPROM Clock	
	wire 		[5:0] SD_COUNTER;			// Counter for EEPROM
	wire				I2C_SCLK;
	wire				I2C_SDAT;
	wire		[7:0]	EEPROM_DATA;
	wire		[7:0] BUS_OUT; 			// Bus wire
	reg		[3:0]	SEL;					// Mux controlling modules
	reg		[7:0]	PRGM_IN;				// reg from programmer
	reg		[2:0] OP;					// ALU op code
	reg		[3:0]	WORD_ADDR;
	reg				GO;					// Flag for programming and testing
	reg				EN;					// Enable flag for Program Counter
	reg				OE;					// wire Enable
	reg				WE;					//	Write Enable
	reg				RESET;				//	Asynchronous Reset
	reg				PRGM;					//	Program mode
	reg				HLT;					// Computer Halt
	reg				CLK;					// 50 Mhz intrenal clock

FPGAComputer uut(
		.BUS_OUT			( BUS_OUT		),
		.CURRENT			( CURRENT		),
		.SEL				( SEL				),
		.PRGM_IN			( PRGM_IN		),
		.CLK				( CLK				),
		.RESET			( RESET			),
		.EN				( EN				),
		.GO				( GO				),
		.OE				( OE				),
		.WE				( WE				),
		.PRGM				( PRGM 			),
		.HLT				( HLT				)
);

initial
begin
	GO = 1'b1;
	CLK = 1'b0;
	RESET = 1'b0;
	OE = 1'b0;
	PRGM = 1'b0;
	HLT = 1'b0;
	PRGM_IN = 8'b0;
	SEL = 4'b0;
	WE = 1'b0;
	#25;
	
	RESET = 1'b1;
	#50;
	
	RESET = 1'b0;
	SEL = 4'b0100;
	PRGM = 1'b1;
	OE = 1'b1;
	PRGM_IN = 8'b01010000;
	RESET = 1'b0;
	GO = 0;
	#50;	
	
	PRGM = 1'b0;
	#50;
	
	OE = 1'b0;
	PRGM_IN = 8'b10100000;
	PRGM = 1'b1;
	#50;
	
	PRGM = 1'b0;
	WE = 1'b1;
end		
	
always
begin
	#50;
	CLK <= ~CLK;
end
endmodule