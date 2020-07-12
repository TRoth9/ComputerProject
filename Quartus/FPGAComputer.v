module FPGAComputer	(
	output 		[3:0] COUNT,				// ProgramCounter
	output reg	[7:0] CURRENT,				// Current module data
	output				ON,					// Turns on PC
	output 		[3:0]	ADDR,					// EEPROM Clock	
	output 		[9:0]	CLK_COUNT,			// EEPROM Clock	
	output 		[5:0] SD_COUNTER,			// Counter for EEPROM
	output		[7:0] BUS_OUT, 			// Bus output
	output		[10:0] OUT,					// Output Register
	inout			[7:0]	EEPROM_DATA,
	output				I2C_SCLK,
	inout					I2C_SDAT,
	input			[3:0]	SEL,					// Mux controlling modules
	input			[3:0]	PRGM_ADDR,			// Address in memory to program
	input			[7:0]	PRGM_IN,				// Input from programmer
	input			[2:0] OP_PRGM,
	input					GO,					// Flag for programming and testing
	input					EN,					// Enable flag for Program Counter
	input					WE,
	input					OE,
	input					RESET,				//	Asynchronous Reset
	input					PRGM,					//	Program mode
	input					HLT,					// Computer Halt
	input					CLK					// 50 Mhz intrenal clock
);

// Priority:
//		PC > ACC > BREG > ALU > MAR > EEPROM 
//		RESET > WE > PRGM > OE

// Separate program mode from the control unit
	// Just set all control ports to wires, output controls from ControlUnit instantiation
	
// Control Parameters //
parameter PC 	 =	4'b0000, //	ProgramCounter
			 ACC 	 = 4'b0001,	//	Accumulator
			 BREG  = 4'b0010,	//	B register
			 ALU 	 = 4'b0011,	//	Arithmetic Logic Unit
			 MAR 	 = 4'b0100,	//	Memory Address Register
			 MEM 	 = 4'b0101,	//	EEPROM on De0-nano
			 IR 	 =	4'b0110,	//	Instruction Register
			 CTRL	 = 4'b0111,	//	Controller/Sequencer
			 OR 	 =	4'b1000,	//	Output Register
			 BUS	 =	4'b1001;	// Bus
			 
// EEPROM Addresses //
parameter WRITE = 8'hA0,
			 READ	 = 8'hA1;

// ALU OP Codes //
parameter ALU_ADD = 3'b000,	// Addition
			 ALU_SUB = 3'b001,	// Subtraction
			 ALU_DEC = 3'b010,	// Decrement
			 ALU_INC = 3'b011,	// Increment
			 ALU_OC  = 3'b100,	// One's Complement
			 ALU_BND = 3'b101,	// Bitwise AND
			 ALU_BOR = 3'b110,	// Bitwise OR
			 ALU_BXR = 3'b111;	// Bitwise XOR		
			 
// Debounce //
reg [15:0]	CNT;	
reg GO_DB;	

wire MCOUNT = &CNT;

// Control Unit //
wire EN_CU;
wire OP_CU;
wire RESET_CU;
wire CLR = RESET || RESET_CU;
		
// Program Counter //
reg [3:0]	PC_IN;

wire	OE_PC;
wire	PRGM_PC;
wire [3:0]	PC_OUT;
wire EN_PC = (EN || EN_CU) & ~HLT;

// Accumulator //
reg [7:0]	ACC_IN;

wire	OE_ACC;
wire	WE_ACC;
wire	PRGM_ACC;
wire [7:0]	ACC_OUT;

// B Register //
reg [7:0]	BREG_IN;

wire	WE_BREG;
wire	PRGM_BREG;
wire [7:0]	BREG_OUT;

// ALU //
reg [7:0]	ALU_IN;

wire	OE_ALU;
wire	PRGM_ALU;			
wire [2:0]	OP;
wire [7:0]	ALU_OUT;	
wire [2:0]	OP_IN = PRGM? OP_PRGM: OP_CU;			

// MAR //
reg [3:0]	MAR_IN;

wire	WE_MAR;
wire	PRGM_MAR;
wire [3:0]	MAR_OUT;

// BUS //
wire		 PRGM_BUS;
reg [7:0] BUS_IN;
reg [7:0] BUS_DATA;
wire [7:0] BUS_REG;

// EEPROM //
wire	DONE;
wire	OE_EEPROM;
wire	WE_EEPROM;
wire	PRGM_EEPROM;
wire [7:0] R_DATA;
wire [7:0] WR_DATA;
wire [7:0] I2C_ADDR;	
wire [3:0] WORD_ADDR = (PRGM_EEPROM)? PRGM_ADDR: MAR_OUT;

// Output Register //
reg [7:0]	OR_IN;

wire	WE_OR;
wire	PRGM_OR;
wire [3:0] 	ANODE;
wire [6:0]	OR_OUT;

// Instruction Register //
reg [3:0]	ADDR_IN;
reg [3:0]	INST_IN;

wire	WE_IR;
wire	OE_IR;
reg	PRGM_IR;
wire [3:0]	INST;
wire [3:0]	ADDR_OUT;

// BUS Output //
assign BUS_OUT =	(OE_PC)?			{4'b0,COUNT}:
						(OE_ACC)?		ACC_OUT:
						(OE_ALU)?		ALU_OUT:
						(OE_IR)?			{4'b0,ADDR_OUT}:
						(OE_EEPROM)?	R_DATA:
						BUS_DATA;									// If we are not outputting, we hold previous data
									
assign ADDR = MAR_OUT;
									
// EEPROM Output //
assign EEPROM_DATA = (OE_EEPROM)? R_DATA: 		// Output read contents
							(WE_EEPROM)? BUS_DATA: 		// Output BUS contents
							(PRGM_EEPROM)? PRGM_IN:		// Output PRGM contents
							8'bz;

// EEPROM Input //
assign WR_DATA = (WE_EEPROM || PRGM_EEPROM)? EEPROM_DATA: 8'bz;

// Output Register Output //			
assign OUT = {ANODE,OR_OUT};


ProgramCounter PC_1 (
	.COUNT		( COUNT		),
	.ON			( ON			),
	.PC_IN		( PC_IN		),
	.PRGM			( PRGM_PC	),
	.EN			( EN_PC		),
	.RESET		( CLR			),
	.CLK			( CLK			)
);

Accumulator	ACC_1	(
	.ACC_OUT		( ACC_OUT	),
	.ACC_IN		( ACC_IN		),
	.WE			( WE_ACC		),
	.PRGM			( PRGM_ACC	),
	.RESET		( CLR			),
	.CLK			( CLK			)
);

BRegister BREG_1 (
	.BREG_OUT	( BREG_OUT		),
	.BREG_IN		( BREG_IN		),
	.WE			( WE_BREG		),
	.PRGM			( PRGM_BREG		),
	.RESET		( CLR				),
	.CLK			( CLK				)
);

ALU_REG	ALU_1	(
	.ALU_OUT		( ALU_OUT	),	
	.ACC_IN		( ACC_OUT	),	
	.BREG_IN		( BREG_OUT	),
	.OP			( OP_IN		),			
	.CLK			( CLK			)
);

ADDR_REG	MAR_1	(
	.MAR_OUT		( MAR_OUT	),
	.MAR_IN		( MAR_IN		),
	.WE			( WE_MAR		),
	.PRGM			( PRGM_MAR	),
	.CLK			( CLK			),
	.RESET		( CLR			)
);

InstructionReg	IR_1 (
	.INST_OUT	( INST		),
	.ADDR_OUT	( ADDR_OUT	),		
	.ADDR_IN		( ADDR_IN	),	
	.INST			( INST_IN	),		
	.WE			( WE_IR		),		
	.PRGM			( PRGM_IR	),
	.CLK			( CLK			),
	.RESET		( CLR			)
);
	
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
	.OP				( OP_CU			),
	.I2C_ADDR		( I2C_ADDR		),
	.SEL				( SEL				),
	.INST				( INST			),
	.PRGM				( PRGM			),
	.GO				( ~GO				), // use go_db when compiling for hardware
	.OE				( OE				),
	.WE				( WE				),
	.DONE				( DONE			),
	.CLK				( CLK				),
	.CLR				( RESET_CU		)
);
	
EEPROM EEPROM_1	(
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
	.RESET			( CLR				)
);

OP_REG OR_1	(
	.OR_OUT	( OR_OUT		),
	.ANODE	( ANODE		),
	.OR_IN	( OR_IN		),
	.WE		( WE_OR		),
	.PRGM		( PRGM_OR	),
	.RESET	( CLR			),
	.CLK		( CLK			)
);

// Debounce
always @(posedge CLK) begin	
	if (GO_DB != GO)
		CNT <= 0;	
	else 
	begin
		CNT <= CNT + 16'd1;
		if (MCOUNT) 
			GO_DB <= ~GO_DB;
	end					
end

// Module Data 
always @(*)//negedge CLK or posedge CLR)
begin
	PC_IN = 0;
	ACC_IN = 0;
	BREG_IN = 0;
	MAR_IN = 0;
	OR_IN = 0;
	ADDR_IN = 0;
	INST_IN = 0;
	BUS_IN = 0;
	
	if (CLR) 
	begin
		PC_IN = 0;
		ACC_IN = 0;
		BREG_IN = 0;
		MAR_IN = 0;
		OR_IN = 0;
		ADDR_IN = 0;
		INST_IN = 0;
		BUS_IN = 0;
	end
	else if (PRGM || WE)
	begin
		case (SEL) // When WE is high, bus contents take priority over PRGM_IN
			PC		:	begin
							if (PRGM_PC)
								PC_IN <= PRGM_IN[3:0];
						end
			ACC	:	begin
							if (WE_ACC)
								ACC_IN <= BUS_DATA;
							else if (PRGM_ACC)
								ACC_IN <= PRGM_IN;
						end
			BREG	:	begin
							if (WE_BREG)
								BREG_IN <= BUS_DATA;
							else if (PRGM_BREG)
								BREG_IN <= PRGM_IN;
						end
			MAR	:	begin
							if (WE_MAR)
								MAR_IN <= BUS_DATA[3:0];
							else if (PRGM_MAR)
								MAR_IN <= PRGM_IN[3:0];
						end
			OR		:	begin
							if (WE_OR)
								OR_IN	<= BUS_DATA;
							else if (PRGM_OR)
								OR_IN	<= PRGM_IN;
						end
			IR		:	begin
							if (WE_IR)
								{INST_IN,ADDR_IN}	<= BUS_DATA;
							else if (PRGM_IR)
								{INST_IN,ADDR_IN}	<= {PRGM_IN[7:4],PRGM_ADDR};
						end
			BUS	:	begin
							if (PRGM_BUS)
								BUS_IN <= PRGM_IN;
						end
			default: begin
							PC_IN <= 0;
							ACC_IN <= 0;
							BREG_IN <= 0;
							MAR_IN <= 0;
							OR_IN <= 0;
							ADDR_IN <= 0;
							INST_IN <= 0;
							BUS_IN <= 0;
						end
		endcase
	end
end		


// Outputs currently selected module for easier testing
always @(*)
begin
	CURRENT <= 0;
	
	case (SEL)
		PC		:	CURRENT <= {4'b0,COUNT};
		ACC	:	CURRENT <= ACC_OUT;
		BREG	:	CURRENT <= BREG_OUT;
		ALU	:	CURRENT <= ALU_OUT;
		MEM	:	CURRENT <= R_DATA;
		MAR	:	CURRENT <= {4'b0,MAR_OUT};
		OR		:	CURRENT <= OR_OUT;
		IR		:	CURRENT <= {INST,ADDR_OUT};
		default: CURRENT <= {4'b0,COUNT};
	endcase
end

// Latch for BUS data //
always @(*)
begin
	BUS_DATA <= 8'b0;
	
	if (CLR)
		BUS_DATA <= 8'b0;
	else if (PRGM_BUS)
		BUS_DATA <= BUS_IN;
	else if (OE_PC)
		BUS_DATA <= {4'b0,COUNT};
	else if (OE_ACC)
		BUS_DATA <= ACC_OUT;
	else if (OE_ALU)
		BUS_DATA <= ALU_OUT;
	else if (OE_EEPROM)
		BUS_DATA <=	R_DATA;
	else if (OE_IR)
		BUS_DATA <= {INST,ADDR_OUT};
end

endmodule