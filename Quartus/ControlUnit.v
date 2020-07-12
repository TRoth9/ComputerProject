module ControlUnit	(
	output reg	PRGM_PC,
	output reg	PRGM_ACC,
	output reg	PRGM_BREG,
	output reg	PRGM_MAR,
	output reg	PRGM_EEPROM,
	output reg	PRGM_OR,
	output reg	PRGM_BUS,
	output reg	OE_PC,
	output reg	OE_ACC,
	output reg	OE_ALU,	
	output reg	OE_EEPROM,		
	output reg	OE_IR,
	output reg	WE_ACC,
	output reg	WE_BREG,		
	output reg	WE_MAR,	
	output reg	WE_EEPROM,	
	output reg	WE_OR,	
	output reg	WE_IR,	
	output reg	EN,
	output reg	DONE_CU,	// Flag to indicate when we finish the execution stage
	output reg [2:0] OP,	// ALU OP codes
	output reg [7:0] I2C_ADDR, 
	input	[3:0]	SEL,		// Currently selected module for programming
	input	[3:0]	INST,		// Instruction
	input			GO,		// Push-button for inputting programmed data
	input			OE,		// Output enable from programmer
	input			WE,		// Output enable from programmer
	input			PRGM,		// Program flag
	input			DONE,		// Flag from EEPROM when finished read/write operation
	input	 		CLK,		// 50 Mhz internal clock
	input			CLR		// Master clear
);

// Current Operations:
//		Load Accumulator, Load B Register, Add, Subtract, Output

// USE DIP SWITCHES ON BOARD TO SELECT A PRE-COMPILED PROGRAM (that we write and program onto the board)
// DIP SWITCH MUX TO CONTROLL ENABLE FOR PROGRAM

// Module Parameters //
parameter 
			PC		= 4'b0000,	//	ProgramCounter
			ACC	= 4'b0001,	//	Accumulator
			BREG	= 4'b0010,	//	B register
			ALU	= 4'b0011,	//	Arithmetic Logic Unit
			MAR	= 4'b0100,	//	Memory Address Register
			MEM	= 4'b0101,	//	EEPROM on De0-nano
			IR		= 4'b0110,	//	Instruction Register
			CTRL	= 4'b0111,	//	Controller/Sequencer
			OR		= 4'b1000,	//	Output Register
			BUS	= 4'b1001;	// Bus
			 
// Control Unit Parameters //
parameter 
			LDA	= 4'b0001,		// Write to Accumulator
			LDB	= 4'b0010,		// Write to B Register
			ADD	= 4'b0011,		// Add Accumulator + B Register
			SUB	= 4'b0100,		// Subtract Accumulator - B Register
			OUT	= 4'b1000;		// Output Register

// ALU OP Codes //
parameter 
			ALU_ADD = 3'b000,	// Addition
			ALU_SUB = 3'b001,	// Subtraction
			ALU_DEC = 3'b010,	// Decrement
			ALU_INC = 3'b011,	// Increment
			ALU_OC  = 3'b100,	// One's Complement
			ALU_BND = 3'b101,	// Bitwise AND
			ALU_BOR = 3'b110,	// Bitwise OR
			ALU_BXR = 3'b111;	// Bitwise XOR			 

// Instruction Register //
//wire	[1:0] FETCH;

// Control Unit //
reg [2:0] CYCLE		= 3'd0;		// Register value for current execution CYCLES of operation
reg [1:0] FETCH_CNT	= 2'd0;		// Register value for current Fetch stage
reg [2:0] CYCLES		= 3'd0;		// Register value for total execution CYCLES of operation

wire FETCH = ~PRGM && ((CYCLE >= CYCLES) || (CYCLE <= 1)) && ~CLR;
wire EXECUTE = (CYCLE >= 3'd1) && (CYCLE <= CYCLES);

// EEPROM Addresses
always @(*)
begin
	I2C_ADDR <= 8'h0;	
	if (PRGM_EEPROM || WE_EEPROM)
		I2C_ADDR <= 8'hA0;	// Write address
	else if (OE_EEPROM)
		I2C_ADDR <= 8'hA1;	// Read address
end
		
always @(*)
begin
	CYCLES = 3'd0;
	case (INST)
		LDA:	CYCLES = 3'd3;
		LDB:	CYCLES = 3'd3;
		ADD:	CYCLES = 3'd3;
		SUB:	CYCLES = 3'd3;
		OUT:	CYCLES = 3'd2;
	endcase
end

always @(negedge CLK) 
begin	
	PRGM_PC <= 1'b0;
	PRGM_ACC <= 1'b0;
	PRGM_BREG <= 1'b0;
	PRGM_MAR <= 1'b0;
	PRGM_EEPROM <= 1'b0;
	PRGM_OR <= 1'b0;
	PRGM_BUS <= 1'b0;
	OE_PC <= 1'b0;
	OE_ACC <= 1'b0;
	OE_ALU <= 1'b0;	
	OE_EEPROM <= 1'b0;
	OE_IR <= 1'b0;
	WE_ACC <= 1'b0;
	WE_BREG <= 1'b0;		
	WE_MAR <= 1'b0;
	WE_EEPROM <= 1'b0;	
	WE_OR <= 1'b0;
	WE_IR <= 1'b0;	
	if (CLR)
	begin
		PRGM_PC <= 1'b0;
		PRGM_ACC <= 1'b0;
		PRGM_BREG <= 1'b0;
		PRGM_MAR <= 1'b0;
		PRGM_EEPROM <= 1'b0;
		PRGM_OR <= 1'b0;
		PRGM_BUS <= 1'b0;
		OE_PC <= 1'b0;
		OE_ACC <= 1'b0;
		OE_ALU <= 1'b0;	
		OE_EEPROM <= 1'b0;
		OE_IR <= 1'b0;
		WE_ACC <= 1'b0;
		WE_BREG <= 1'b0;		
		WE_MAR <= 1'b0;
		WE_EEPROM <= 1'b0;	
		WE_OR <= 1'b0;
		WE_IR <= 1'b0;	
	end
	else if (PRGM && GO)
	begin
		case (SEL)				// PRGM will always be on for each module we select
			PC		:	begin
							PRGM_PC	<= PRGM;
							OE_PC		<= OE;
						end
			ACC	:	begin
							PRGM_ACC	<= PRGM;
							WE_ACC	<= WE;
							OE_ACC	<= OE;
						end	
			BREG	:	begin
							PRGM_BREG	<= PRGM;
							WE_BREG		<= WE;
						end
			ALU	: 	begin
							OE_ALU		<= OE;
						end
			MAR	:	begin
							PRGM_MAR	<= PRGM;
							WE_MAR	<= WE;
						end	
			MEM	:	begin
							PRGM_EEPROM	<= PRGM;
							WE_EEPROM	<= WE;
							OE_EEPROM	<= OE;
						end	
			OR		:	begin
							PRGM_OR	<= PRGM;
							WE_OR		<= WE;
						end	
			BUS	:	begin
							PRGM_BUS	<= PRGM;
						end	
		endcase
	end
	// Fetch Stage
	else if (FETCH)				// Restart Fetch stage when finished execution
	begin
		DONE_CU <= 0;
		
		case (FETCH_CNT)
			2'd0:	begin
						OE_PC			<= 1;		// Output ProgramCounter to BUS
						WE_MAR		<= 1;		// Load MAR with ProgramCounter address
						FETCH_CNT	<= FETCH_CNT + 1;	// Next fetch cycle
					end
			2'd1:	begin
						OE_PC			<= 0;			
						WE_MAR		<= 0;
						OE_EEPROM	<= 1;		// Output instruction and address from address stored in MAR to BUS
						
						if (DONE)				// Wait for EEPROM to finish operation
						begin	
							WE_IR 		<= 1;		// Load IR with instruction and memory address of new data
							EN		 		<= 1;		// Enable ProgramCounter for next address instruction
							CYCLE			<= 3'd1;	// Start Decoding Stage
							FETCH_CNT 	<= FETCH_CNT + 1;		
						end
					end
			2'd2:	begin
						OE_EEPROM	<= 0;		
						WE_IR 		<= 0;		
						EN		 		<= 0;	
//						CYCLE			<= 3'd1;	// Start Decoding Stage
						FETCH_CNT 	<= FETCH_CNT + 1;	
					end
			default:	FETCH_CNT <= 0;
		endcase
	end
	else 
		FETCH_CNT <= 1'b0;
		
	// Decode and Execute Stage
	if (INST == LDA && EXECUTE) 	// Load Accumulator
	begin
		DONE_CU <= 0;
		
		case (CYCLE)
			3'd1:	begin
						OE_IR			<= 1;
						WE_MAR		<= 1;
						CYCLE			<= CYCLE + 1;
					end
			3'd2:	begin
						OE_IR			<= 0;
						WE_MAR		<= 0;
						OE_EEPROM	<= 1;
						
						if (DONE) 
						begin
							WE_ACC 	<= 1;
							CYCLE		<= CYCLE + 1;
						end
					end
			3'd3:	begin
						OE_EEPROM	<= 0;		
						WE_ACC 		<= 0;
						DONE_CU		<= 1;
						CYCLE			<= CYCLE + 1;
					end
			default:	CYCLE <= 0;
		endcase
	end
	else if (INST == LDB && EXECUTE) 	// Load B Register
	begin
		DONE_CU <= 0;
		
		case (CYCLE)
			3'd1:	begin
						OE_IR			<= 1;
						WE_MAR		<= 1;
						CYCLE			<= CYCLE + 1;
					end
			3'd2:	begin
						OE_IR			<= 0;
						WE_MAR		<= 0;
						OE_EEPROM	<= 1;
						
						if (DONE) 
						begin
							WE_BREG 	<= 1;
							CYCLE		<= CYCLE + 1;
						end
					end
			3'd3:	begin
						OE_EEPROM	<= 0;		
						WE_BREG 		<= 0;
						DONE_CU		<= 1;
						CYCLE			<= CYCLE + 1;
					end
			default:	CYCLE <= 0;
		endcase
		
	end
	else if (INST == ADD && EXECUTE)		// ACC + BReg, output to ACC
	begin
		DONE_CU	<= 0;
		
		case (CYCLE)
			3'd1:	begin
						OP		 	<= ALU_ADD;
						CYCLE		<= CYCLE + 1;
					end
			3'd2:	begin
						OE_ALU 	<= 1;
						WE_ACC 	<= 1;
						CYCLE		<= CYCLE + 1;
					end
			3'd3: begin
						OP		 	<= 4'bz;
						OE_ALU 	<= 0;
						WE_ACC 	<= 0;
						DONE_CU	<= 1;
						CYCLE		<= CYCLE + 1;			
					end
			default:	CYCLE <= 0;
		endcase
	end
	else if (INST == SUB && EXECUTE)		// ACC - BReg, output to ACC
	begin
		DONE_CU <= 0;
		
		case (CYCLE)
			3'd1:	begin
						OP		 	<= ALU_SUB;
						CYCLE		<= CYCLE + 1;
					end
			3'd2:	begin
						OE_ALU 	<= 1;
						WE_ACC 	<= 1;
						CYCLE		<= CYCLE + 1;
					end
			3'd3: begin
						OP		 	<= 4'bz;
						OE_ALU 	<= 0;
						WE_ACC 	<= 0;
						DONE_CU	<= 1;
						CYCLE		<= CYCLE + 1;			
					end
			default:	CYCLE <= 0;
		endcase
	end
	else if (INST == OUT && EXECUTE)		// Output Accumulator 
	begin
		DONE_CU <= 0;
		
		case (CYCLE)
			3'd1:	begin
						OE_ACC	<= 1;
						WE_OR		<= 1;
						CYCLE		<= CYCLE + 1;
					end
			3'd2:	begin
						OE_ACC	<= 0;
						WE_OR		<= 0;
						CYCLE		<= 2'd0;
						DONE_CU	<= 1;
						CYCLE		<= CYCLE + 1;
					end
			default:	CYCLE <= 0;
		endcase
	end
	else
		DONE_CU <= 0;
		
end

endmodule