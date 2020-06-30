module FPGAComputer	(
	output 		[3:0] COUNT,				// ProgramCounter
	output reg	[7:0] CURRENT,				// Current module data
	output				ON,					// Turns on PC
	output				I2C_SCLK,
	inout					I2C_SDAT,
	inout			[7:0] BUS_OUT, 			// Bus output
	input			[3:0]	SEL,					// Mux controlling modules
	input			[7:0]	PRGM_IN,				// Input from programmer
	input			[2:0] OP,
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
//		PC > ACC > BREG > ALU 
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
			 
// Debounce Registers //
reg [15:0]	CNT;	
reg 			GO_DB;	
wire 			MCOUNT = &CNT;
		
// Program Counter Registers //
reg	OE_PC;
reg	WE_PC;
reg	RS_PC;
reg	PRGM_PC;
reg [3:0]	PC_IN;

// Program Counter  Wires //
wire [3:0]	PC_OUT;
wire EN_PC = EN & ~HLT;

// Accumulator Registers //
reg	OE_ACC;
reg	WE_ACC;
reg	RS_ACC;
reg	PRGM_ACC;

reg [7:0]	ACC_IN;

// Accumulator Wires //
wire [7:0]	ACC_OUT;

// B Register Registers //
reg	OE_BREG;
reg	WE_BREG;
reg	RS_BREG;
reg	PRGM_BREG;

reg [7:0]	BREG_IN;

// B Register Wires //
wire [7:0]	BREG_OUT;

// ALU Registers //
reg	OE_ALU;
reg	PRGM_ALU;

//reg [2:0]	OP;									// OP code for ALU operation
reg [7:0]	ALU_IN;

// ALU Wires //
wire [7:0]	ALU_OUT;

// BUS Registers //
reg [7:0] BUS_DATA;

// BUS Output //
assign BUS_OUT =	(CLK & OE_PC)?		COUNT<<<4:
						(CLK & OE_ACC)?	ACC_OUT:
						(CLK & OE_BREG)?	BREG_OUT:
						(CLK & OE_ALU)?	ALU_OUT:
						BUS_DATA;					// If we are not outputting, we hold previous data

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
		RS_PC		<= 1;
		RS_ACC	<= 1;		
		RS_BREG	<= 1;
		OE_PC		<= 0; 
		OE_ACC	<= 0;
		OE_BREG	<= 0;
		OE_ALU	<= 0;
	end
	else 
	begin
		PRGM_PC		<= 0;
		PRGM_ACC		<= 0;
		PRGM_BREG	<= 0;
		WE_PC			<= 0;
		WE_ACC		<= 0;
		WE_BREG		<= 0;
		OE_PC			<= 0; 
		OE_ACC		<= 0;
		OE_BREG		<= 0;
		OE_ALU		<= 0;
		RS_PC			<= 0;
		RS_ACC		<= 0;	
		RS_BREG		<= 0;
						
		if (~GO) 
		begin			
			case (SEL)
				PC		:	begin
								PRGM_PC	<= PRGM;
								WE_PC		<= WE;
								OE_PC		<= OE;
							end
				ACC	:	begin
								PRGM_ACC	<= PRGM;
								WE_ACC	<= WE;
								OE_ACC	<= OE;
							end
				BREG	:	begin
								PRGM_BREG	<= PRGM;
								WE_BREG	<= WE;
								OE_BREG	<= OE;
							end
				ALU	:	begin
								OE_ALU	<= OE;
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
	end
	else
	begin
		PC_IN <= 0;
		ACC_IN <= 0;
		BREG_IN <= 0;
		
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
		endcase
	end
end		

// Outputs currently selected module for easier testing
always @(*)
begin
	CURRENT <= 0;
	
	case (SEL)
		PC		:	CURRENT <= COUNT<<<4;
		ACC	:	CURRENT <= ACC_OUT;
		BREG	:	CURRENT <= BREG_OUT;
		ALU	:	CURRENT <= ALU_OUT;
	endcase
end

// Latch for BUS data //
always @(COUNT or ACC_OUT or BREG_OUT or ALU_OUT)
begin
	if	(OE_PC)
		BUS_DATA <= COUNT<<<4;
	else if	(OE_ACC)
		BUS_DATA <= ACC_OUT;
	else if	(OE_BREG)
		BUS_DATA <= BREG_OUT;
	else if	(OE_ALU)
		BUS_DATA <= ALU_OUT;
end

// ALU OP codes
always @(posedge CLK)
begin

end
endmodule