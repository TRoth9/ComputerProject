module FPGAComputer	(
	output 		[3:0] COUNT,				// ProgramCounter
	output reg	[7:0] CURRENT,				// Current module data
	output				ON,					// Turns on PC
	output 		[9:0]	CLK_COUNT,			// EEPROM Clock	
	output 		[5:0] SD_COUNTER,			// Counter for EEPROM
	output		[7:0] OUT,					// Output Register
	output				I2C_SCLK,
	inout					I2C_SDAT,
	inout			[7:0]	EEPROM_DATA,
	inout			[7:0] BUS_OUT, 			// Bus output
	input			[3:0]	SEL,					// Mux controlling modules
	input			[7:0]	PRGM_IN,				// Input from programmer
	input			[2:0] OP,					// ALU op code
	input			[3:0]	WORD_ADDR,
	input					GO,					// Flag for programming and testing
	input					EN,					// Enable flag for Program Counter
	input					OE,					// Output Enable
	input					WE,					//	Write Enable
	input					RESET,				//	Asynchronous Reset
	input					PRGM,					//	Program mode
	input					HLT,					// Computer Halt
	input					CLK					// 50 Mhz intrenal clock
);

// Priority:
//		PC > ACC > BREG > ALU > EEPROM > MAR
//		RESET > PRGM > WE > OE
//		PRGM & WE > EN

// Control Parameters //
parameter PC 	 =	4'b0000, //	ProgramCounter
			 ACC 	 = 4'b0001,	//	Accumulator
			 BREG  = 4'b0010,	//	B register
			 ALU 	 = 4'b0011,	//	Arithmetic Logic Unit
			 MAR 	 = 4'b0100,	//	Memory Address Register
			 MEM 	 = 4'b0101,	//	EEPROM on De0-nano
			 IR 	 =	4'b0110,	//	Instruction Register
			 CNTRL = 4'b0111,	//	Controller/Sequencer
			 OR 	 =	4'b1000,	//	Output Register
			 BUS	 =	4'b1001,	// Bus
			 WRITE = 8'hA0,	// EEPROM Addresses
			 READ	 = 8'hA1;

// ALU OP Codes //
parameter ADD = 3'b000,	// Addition
			 SUB = 3'b001,	// Subtraction
			 DEC = 3'b010,	// Decrement
			 INC = 3'b011,	// Increment
			 OC  = 3'b100,	// One's Complement
			 BND = 3'b101,	// Bitwise AND
			 BOR = 3'b110,	// Bitwise OR
			 BXR = 3'b111;	// Bitwise XOR		
			 
// Debounce //
reg [15:0]	CNT;	
reg 			GO_DB;	

wire 			MCOUNT = &CNT;
		
// Program Counter //
reg	OE_PC;
reg	WE_PC;
reg	RS_PC;
reg	PRGM_PC;
reg [3:0]	PC_IN;

wire [3:0]	PC_OUT;
wire EN_PC = EN & ~HLT;

// Accumulator //
reg	OE_ACC;
reg	WE_ACC;
reg	RS_ACC;
reg	PRGM_ACC;
reg [7:0]	ACC_IN;

wire [7:0]	ACC_OUT;

// B Register //
reg	OE_BREG;
reg	WE_BREG;
reg	RS_BREG;
reg	PRGM_BREG;
reg [7:0]	BREG_IN;

wire [7:0]	BREG_OUT;

// ALU //
reg	OE_ALU;
reg	PRGM_ALU;
//reg [2:0]	OP;									// OP code for ALU operation
reg [7:0]	ALU_IN;

wire [7:0]	ALU_OUT;

// MAR //
reg	OE_MAR;
reg	WE_MAR;
reg	RS_MAR;
reg	PRGM_MAR;
reg [7:0]	MAR_IN;

wire [7:0]	MAR_OUT;

// BUS //
reg		 RS_BUS;
reg		 PRGM_BUS;
reg [7:0] BUS_IN;
reg [7:0] BUS_DATA;


// EEPROM //
reg	OE_EEPROM;
reg	WE_EEPROM;
reg	RS_EEPROM;
reg	PRGM_EEPROM;
reg [7:0]	I2C_ADDR;			// I2C Address

wire	DONE;
wire [7:0] R_DATA;
wire [7:0] WR_DATA;
wire [7:0] EEPROM_OUT;

// Output Register //
reg	WE_OR;
reg	RS_OR;
reg	PRGM_OR;
reg [7:0]	OR_IN;

wire [7:0]	OR_OUT;

// BUS Output //
assign BUS_OUT =	(OE_PC)?			{COUNT,4'b0}:
						(OE_ACC)?		ACC_OUT:
						(OE_BREG)?		BREG_OUT:
						(OE_ALU)?		ALU_OUT:
						(OE_MAR)?		{MAR_OUT,4'b0}:
						(OE_EEPROM)?	EEPROM_DATA:
						BUS_DATA;										// If we are not outputting, we hold previous data
									
// What about programming the EEPROM from PRGM_IN? Read from BUS?
									
// EEPROM Output //
assign EEPROM_DATA = (OE_EEPROM)? R_DATA:
							(WE_EEPROM)? BUS_OUT:
							(PRGM_EEPROM)? PRGM_IN:
							8'bz;

// Output Register Output //			
assign OUT = OR_OUT;

// EEPROM Input //
assign WR_DATA = (WE_EEPROM || PRGM_EEPROM)? EEPROM_DATA: 8'bz;

ProgramCounter PC_1 (
	.COUNT		( COUNT		),
	.ON			( ON			),
	.PC_IN		( PC_IN		),
	.WE			( WE_PC		),
	.PRGM			( PRGM_PC	),
	.EN			( EN_PC		),
	.RESET		( RS_PC		),
	.CLK			( CLK			)
);

Accumulator	ACC_1	(
	.ACC_OUT		( ACC_OUT	),
	.ACC_IN		( ACC_IN		),
	.WE			( WE_ACC		),
	.PRGM			( PRGM_ACC	),
	.RESET		( RS_ACC		),
	.CLK			( CLK			)
);

BRegister	BREG_1	(
	.BREG_OUT	( BREG_OUT		),
	.BREG_IN		( BREG_IN		),
	.WE			( WE_BREG		),
	.PRGM			( PRGM_BREG		),
	.RESET		( RS_BREG		),
	.CLK			( CLK				)
);

ALU_REG	ALU_1	(
	.ALU_OUT		( ALU_OUT	),	
	.ACC_IN		( ACC_OUT	),	
	.BREG_IN		( BREG_OUT	),
	.OP			( OP			),			
	.CLK			( CLK			)
);

ADDR_REG	MAR_1	(
	.MAR_OUT		( MAR_OUT	),
	.MAR_IN		( MAR_IN		),
	.WE			( WE_MAR		),
	.PRGM			( PRGM_MAR	),
	.CLK			( CLK			),
	.RESET		( RS_MAR		)
);		
EEPROM	EEPROM_1	(
		.I2C_SCLK		( I2C_SCLK		),
		.CLK_COUNT 		( CLK_COUNT		),
		.SD_COUNTER		( SD_COUNTER	),
		.DONE				( DONE			),
		.EEPROM_OUT		( R_DATA			),
		.EEPROM_IN		( WR_DATA		),
		.I2C_SDAT		( I2C_SDAT		),
		.I2C_ADDR		( I2C_ADDR		),
		.WORD_ADDR		( WORD_ADDR		),
		.GO_DB			( GO_DB			),
		.CLK				( CLK				),
		.RESET			( RS_EEPROM		)
);

OP_REG	OR_1	(
	.OP_OUT	( OR_OUT		),
	.OP_IN	( OR_IN		),
	.WE		( WE_OR		),
	.PRGM		( PRGM_OR	),
	.RESET	( RS_OR		),
	.CLK		( CLK			)
);

// Debounce
always @(posedge CLK) begin	
	if (GO_DB != GO)
		CNT <= 0;	// nothing happening
	else 
	begin
		CNT <= CNT + 16'd1;
		if (MCOUNT) 
			GO_DB <= ~GO_DB;
	end					
end

// Control Signals
always @(negedge CLK or posedge RESET)
begin	
	if (RESET) 
	begin		
		RS_PC			<= 1;
		RS_ACC		<= 1;		
		RS_BREG		<= 1;
		RS_MAR		<= 1;
		RS_OR			<= 1;
		RS_BUS		<= 1;
		PRGM_PC		<= 0;
		PRGM_ACC		<= 0;
		PRGM_BREG	<= 0;
		PRGM_MAR		<= 0;
		PRGM_EEPROM	<= 0;
		PRGM_OR		<= 0;
		WE_PC			<= 0;
		WE_ACC		<= 0;
		WE_BREG		<= 0;
		WE_MAR		<= 0;
		WE_EEPROM	<= 0;
		WE_OR			<= 0;
		OE_PC			<= 0; 
		OE_ACC		<= 0;
		OE_BREG		<= 0;
		OE_ALU		<= 0;
		OE_MAR		<= 0;
		OE_EEPROM	<= 0;
	end
	else 
	begin
		PRGM_PC		<= 0;
		PRGM_ACC		<= 0;
		PRGM_BREG	<= 0;
		PRGM_MAR		<= 0;
		PRGM_EEPROM	<= 0;
		PRGM_OR		<= 0;
		PRGM_BUS		<= 0;
		WE_PC			<= 0;
		WE_ACC		<= 0;
		WE_BREG		<= 0;
		WE_MAR		<= 0;
		WE_EEPROM	<= 0;
		WE_OR			<= 0;
		OE_PC			<= 0; 
		OE_ACC		<= 0;
		OE_BREG		<= 0;
		OE_ALU		<= 0;
		OE_MAR		<= 0;
		OE_EEPROM	<= 0;
		RS_PC			<= 0;
		RS_ACC		<= 0;	
		RS_BREG		<= 0;
		RS_MAR		<= 0;
		RS_EEPROM	<= 0;
		RS_OR			<= 0;
		RS_BUS		<= 0;
						
		if (~GO) 
		begin			
			case (SEL)
				PC		:	begin
								PRGM_PC		<= PRGM;
								WE_PC			<= WE;
								OE_PC			<= OE;
							end
				ACC	:	begin
								PRGM_ACC		<= PRGM;
								WE_ACC		<= WE;
								OE_ACC		<= OE;
							end
				BREG	:	begin
								PRGM_BREG	<= PRGM;
								WE_BREG		<= WE;
								OE_BREG		<= OE;
							end
				ALU	:	begin
								OE_ALU		<= OE;
							end
				MAR	:	begin
								PRGM_MAR		<= PRGM;
								WE_MAR		<= WE;
								OE_MAR		<= OE;
							end
				MEM	:	begin
								PRGM_EEPROM	<= PRGM;
								WE_EEPROM	<= WE;
								OE_EEPROM	<= OE;
							end
				OR		:	begin
								PRGM_OR		<= PRGM;
								WE_OR			<= WE;
							end
				BUS	:	begin
								PRGM_BUS		<= PRGM;
							end
			endcase
		end
	end
end

// Module Data 
always @(*)//negedge CLK or posedge RESET)
begin
	if (RESET) 
	begin
		PC_IN <= 0;
		ACC_IN <= 0;
		BREG_IN <= 0;
		MAR_IN <= 0;
		OR_IN <= 0;
		BUS_IN <= 0;
	end
	else
	begin
		PC_IN <= 0;
		ACC_IN <= 0;
		BREG_IN <= 0;
		MAR_IN <= 0;
		OR_IN <= 0;
		BUS_IN <= 0;
		
		case (SEL)
			PC		:	begin
							if (PRGM_PC)
								PC_IN		<= PRGM_IN[7:4];
							else if (WE_PC)
								PC_IN		<= BUS_OUT[7:4];
						end
			ACC	:	begin
							if (PRGM_ACC)
								ACC_IN	<= PRGM_IN;
							else if (WE_ACC)
								ACC_IN	<= BUS_OUT;
						end
			BREG	:	begin
							if (PRGM_BREG)
								BREG_IN	<= PRGM_IN;
							else if (WE_BREG)
								BREG_IN	<= BUS_OUT;
						end
			MAR	:	begin
							if (PRGM_MAR)
								MAR_IN	<= PRGM_IN[7:4];
							else if (WE_MAR)
								MAR_IN	<= BUS_OUT[7:4];
						end
			OR		:	begin
							if (PRGM_OR)
								OR_IN	<= PRGM_IN;
							else if (WE_OR)
								OR_IN	<= BUS_OUT;
						end
			BUS	:	begin
							if (PRGM_BUS)
								BUS_IN	<= PRGM_IN;
						end
		endcase
	end
end		

// EEPROM
always @(*)
begin
	if (PRGM_EEPROM || WE_EEPROM)
		I2C_ADDR = 8'hA0; // Write address
	else if (OE_EEPROM)
		I2C_ADDR = 8'hA1; // Read address
	else
		I2C_ADDR = 8'hz; 	// Nothing
end
		

// Outputs currently selected module for easier testing
always @(*)
begin
	CURRENT <= 0;
	
	case (SEL)
		PC		:	CURRENT <= {COUNT,4'b0};
		ACC	:	CURRENT <= ACC_OUT;
		BREG	:	CURRENT <= BREG_OUT;
		ALU	:	CURRENT <= ALU_OUT;
		MEM	:	CURRENT <= R_DATA;
		MAR	:	CURRENT <= {MAR_OUT,4'b0};
		OR		:	CURRENT <= OR_OUT;
	endcase
end

// Latch for BUS data //
always @(posedge CLK or posedge RESET)//COUNT or ACC_OUT or BREG_OUT or ALU_OUT or MAR_OUT or R_DATA or BUS_IN or posedge RESET)
begin
	if (RESET)
		BUS_DATA <= 8'b0;
	else if	(PRGM_BUS)
		BUS_DATA <= BUS_IN;
	else if (OE_PC)
		BUS_DATA <= {COUNT,4'b0};
	else if	(OE_ACC)
		BUS_DATA <= ACC_OUT;
	else if	(OE_BREG)
		BUS_DATA <= BREG_OUT;
	else if	(OE_ALU)
		BUS_DATA <= ALU_OUT;
	else if	(OE_MAR)
		BUS_DATA <= {MAR_OUT,4'b0};
	else if	(OE_EEPROM)
		BUS_DATA <=	R_DATA;
end

endmodule