`timescale 1ns			/100ps
module EEPROM_tb ();
		wire 			I2C_SCLK;		
		wire	[9:0]	CLK_COUNT;			// EEPROM Clock	
		wire	[5:0] SD_COUNTER;
		wire	[7:0]	EEPROM_DATA;
		wire 			I2C_SDAT;
		reg	[7:0]	I2C_ADDR;					// I2C Address
		reg	[3:0]	WORD_ADDR;
		reg			GO_DB;						// go_db from top level
		reg			CLK;
		reg			RESET;
		
		reg	[7:0] WR_DATA;
		
		assign EEPROM_DATA = (I2C_ADDR == 8'hA0)? WR_DATA : 8'bz;
		

		EEPROM	uut(
		.I2C_SCLK		( I2C_SCLK		),		
		.CLK_COUNT		( CLK_COUNT		),			// EEPROM Clock	
		.SD_COUNTER		( SD_COUNTER	),
		.EEPROM_DATA	( EEPROM_DATA	),
		.I2C_SDAT		( I2C_SDAT		),
		.I2C_ADDR		( I2C_ADDR		),				// I2C Address
		.WORD_ADDR		( WORD_ADDR		),
		.GO_DB			( GO_DB			),				// go_db from top level
		.CLK				( CLK				),
		.RESET			( RESET			)
	);
	
	initial
	begin
//		I2C_ADDR = 8'hA0; // Write address
		I2C_ADDR = 8'hA1; // Read address
		WORD_ADDR = 4'b0;
		GO_DB = 1'b0;
		CLK = 1'b0;
		RESET = 1'b0;
		WR_DATA = 8'b01010101;
		RESET = 1'b1;
		#25;
		
		RESET = 1'b0;
		GO_DB = 1;
	end		
		
	always
	begin
		#50;
		CLK <= ~CLK;
	end
endmodule