`timescale 1ns			/100ps
module OR_tb();

wire 	[3:0]COUNT;
wire	[7:0]BUS_OUT;
wire	[7:0]CURRENT;
wire	ON;
reg 	[3:0]SEL; //select from 16 modules
reg 	[7:0]PRGM_IN;
reg 	CLK,RESET;
reg 	EN,GO;		//go updates regs for our selected module
reg 	OE,WE,PRGM;
reg 	HLT;	//halt the PC

FPGAComputer uut(
			.COUNT	( COUNT		),
			.BUS_OUT	( BUS_OUT	),
			.CURRENT	( CURRENT	),
			.ON		( ON			),
			.SEL		( SEL			),
			.PRGM_IN	( PRGM_IN	),
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
	
	RESET = 1'b0;				// reset
	SEL = 4'b1001;				// BUS
	GO = 1'b0;	
	#50;
	
	PRGM_IN = 8'b10101010;
	PRGM = 1'b1;				// Program Bus

	#50;
	PRGM = 1'b0;
	
	#50
	SEL = 4'b1000;				// Output Register
	WE = 1'b1;					// Output data from bus
	
	#50;
	WE = 1'b0;
	
	#50;
	SEL = 4'b1001;
	PRGM = 1'b1;
	PRGM_IN = 8'b0;
	
	#50;
	PRGM = 1'b0;
	
	#50;
	SEL = 4'b1000;
end

always begin
	#50;
	CLK = ~CLK;
end

endmodule