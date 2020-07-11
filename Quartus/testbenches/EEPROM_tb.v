`timescale 1ns			/100ps
module EEPROM_tb ();
	wire 	[3:0]	COUNT;
	wire	[7:0]	BUS_OUT;
	wire			DONE;
	wire 			I2C_SCLK;		
	wire	[9:0]	CLK_COUNT;			// EEPROM Clock	
	wire	[5:0] SD_COUNTER;
	wire	[7:0]	EEPROM_DATA;
	wire	[7:0] CURRENT;
	wire 			I2C_SDAT;
	reg			[3:0]	SEL;					// Mux controlling modules
	reg			[7:0]	PRGM_IN;				// Input from programmer
	reg 			OE,WE,PRGM;
	reg			EN,GO;						// go_db from top level
	reg			CLK;
	reg			RESET;
	reg 			HLT;	//halt the PC
		
	reg	[7:0] WR_DATA;
	
	//assign EEPROM_DATA = WR_DATA;

FPGAComputer uut(
		.I2C_SCLK		( I2C_SCLK		),
		.CLK_COUNT 		( CLK_COUNT		),
		.SD_COUNTER		( SD_COUNTER	),
		.DONE				( DONE			),
		.CURRENT			( CURRENT		),
		.EEPROM_DATA	( EEPROM_DATA	),
		.I2C_SDAT		( I2C_SDAT		),
		.COUNT			( COUNT			),
		.BUS_OUT			( BUS_OUT		),
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
	WR_DATA = 0;
	OE = 1'b0;
	WE = 1'b0;
	#25;
	
	PRGM_IN = 8'b00001010;
	PRGM = 1'b1;
	SEL = 4'b0100;
	//OE = 1'b1;
	//WE = 1'b1;
	RESET = 1'b0;
	GO = 0;
	#50;
	
	PRGM = 1'b0;
	#50;	
	
	PRGM_IN = 8'b11110000;
	PRGM = 1'b1;
	SEL = 4'b0101;	
	//WR_DATA = 8'b01010101;
end		
	
always
begin
	#50;
	CLK <= ~CLK;
end
endmodule