module main	(
	output 	[3:0]count,
	output	[7:0]Bus_out,
	output	reg[7:0]curr,
	output	I2C_SCLK,
	inout		I2C_SDAT,
	inout		[7:0]EEPROM_DATA,	// maybe should just be a register?
	output 	on,
	input 	[3:0]sel, //select from 16 modules
	input 	[7:0]in,
	input 	CLK,RESET,
	input		en,go,		//go updates inputs for our selected module
	input		OE,WE,load,
	input 	HLT,	//halt the PC
	input 	SUB
	);
				 
	//NOTE:	WE has priority over OE.
	//			RESET is asynchronous
	//multiplexer selects which module, and enables the inputs for that specific module	
	
	// broke mux and go_db so,ehow
	
	// Control Parameters	
	parameter 	PC 	=	4'b0000, //	ProgramCounter
					Acc 	= 	4'b0001,	//	Accumulator
					Breg 	= 	4'b0010,	//	B register
					ALU 	= 	4'b0011,	//	Arithmetic Logic Unit
					MAR 	= 	4'b0100,	//	Memory Address Register
					MEM 	= 	4'b0101,	//	EEPROM on De0-nano
					IR 	=	4'b0110,	//	Instruction Register
					CNTRL = 	4'b0111,	//	Controller/Sequencer
					OR 	=	4'b1000,	//	Output Register
					BUS	=	4'b1001,	// Bus
					WRITE = 	8'hA0,	// EEPROM Addresses
					READ	= 	8'hA1;
					
	// ALU Op codes
	parameter 	ADD = 3'b000,	// Addition
					NEG = 3'b001,	// Subtraction
					DEC = 3'b010,	// Decrement
					INC = 3'b011,	// Increment
					OC  = 3'b100,	// One's Complement
					BND = 3'b101,	// Bitwise AND
					BOR = 3'b110,	// Bitwise OR
					BXR = 3'b111;	// Bitwise XOR
				 
	logic OE_PC,WE_PC,load_PC,rs_PC,
		 OE_Acc,WE_Acc,load_Acc,rs_Acc,
		 OE_Breg,WE_Breg,load_Breg,rs_Breg,
		 WE_MAR,load_MAR,rs_MAR,
		 OE_ALU,
		 load_Bus,rs_Bus,
		 OE_EEPROM,WE_EEPROM,load_EEPROM,rs_EEPROM;
	
	reg		DONE;			// flag to mark READ/WRITE operations to EEPROM as complete
	reg [2:0]OP;			// Op code for ALU
	reg [3:0]REGS;			// Register value for sel
	reg [7:0]Mem_data;
	reg [7:0]Bus_data;
	reg [7:0]I2C_ADDR;
	
	reg [3:0]PC_out;
	reg [3:0]MAR_out;
	reg [7:0]Breg_out;
	reg [7:0]Acc_out;
	reg [7:0]ALU_out;
	
	reg [3:0]MAR_add;
	reg [3:0]PC_in;
	reg [3:0]MAR_in;
	reg [7:0]Breg_in;
	reg [7:0]Acc_in;
	reg [7:0]Bus_in;
	
	reg [15:0]cnt;		//debounce vars
	reg go_db = 0;
	wire mcount = &cnt;
	
	wire en_PC = en & ~HLT;
	
	ProgramCounter ProgramCounter_1 (
			.COUNT	( count	),
			.PC_OUT	( PC_out	),
			.ON		( on		),
			.PC_IN	( PC_in	),
			.CLK		( CLK		),
			.RESET	( rs_PC	),
			.PRGM		( load_PC),
			.WE		( WE_PC	),
			.OE		( OE_PC	),
			.EN		( en_PC	) //enables counter
	);
												
	Accumulator	Accumulator_1	(
			.Acc_out		( Acc_out	),
			.Acc_in		( Acc_in		),
			.OE			( OE_Acc		),
			.WE			( WE_Acc		),
			.load			( load_Acc	),
			.CLK			( CLK			),
			.RESET		( rs_Acc		)
	);
										 
	BRegister Breg_1	(
			.Breg_out	( Breg_out	),
			.Breg_in		( Breg_in	),
			.OE			( OE_Breg	),
			.WE			( WE_Breg	),
			.load			( load_Breg	),
			.CLK			( CLK			),
			.RESET		( rs_Breg	)
	);			

	ALU_REG ALU_1	(
			.ALU_out	( ALU_out	),
			.Acc_in	( Acc_in		),
			.Breg_in	( Breg_in	),
			.OP		( OP			),
			.OE		( OE_ALU		),
			.CLK		( CLK			)
	);
	
	MemAddReg MAR_1	(
			.MAR_out		( MAR_out	),
			.MAR_in		( MAR_in		),
			.WE			( WE_MAR		),
			.load			( load_MAR	),
			.CLK			( CLK			),
			.RESET		( rs_MAR		)
	);
	
	EEPROM EEPROM_1	(
		.I2C_SCLK		( I2C_SCLK		),
		.EEPROM_DATA	( EEPROM_DATA	),
		.DONE				( DONE			),
		.I2C_SDAT		( I2C_SDAT		),
		.I2C_ADDR		( I2C_ADDR		),			// I2C Address
		.WORD_ADDR		( MAR_out		),
		.GO_DB			( go_db			),			// go_db from top level
		.CLK				( CLK				),
		.RESET			( rs_EEPROM	 	)
	);
								
	BUS Bus_1	(
			.Bus_out		( Bus_out	),
			.Bus_in		( Bus_data	),
			.CLK			( CLK			),
			.RESET		( rs_Bus		)
	);
	// to keep track of currently selected module data
	always @(sel or PC_out or Acc_out or Breg_out or ALU_out or MAR_out) 
	begin							
			curr = 8'b0000000;
			case (sel)
			PC		:	begin		
							curr = PC_out;
						end
			Acc	:	begin					
							curr = Acc_out;
						end
			Breg	:	begin								
							curr = Breg_out;
						end
			ALU	:	begin	
							curr = ALU_out;
						end
			MAR	: 	begin
							curr = MAR_out;
						end
		endcase
	end
	
	// ProgramCounter	
	always @(posedge CLK) 
	begin	
		if (sel == PC)
		begin
			OE_PC			= OE;
			WE_PC 		= WE;
			load_PC		= load;
			rs_PC			= RESET;		
		end
	end	
	
	// Accumulator	
	always @(posedge CLK) 
	begin	
		if (sel == Acc)
		begin
			OE_Acc		= OE;
			WE_Acc		= WE;
			load_Acc		= load;
			rs_Acc		= RESET;
		end
	end
	
	// B Register	
	always @(posedge CLK) 
	begin	
		if (sel == Breg)
		begin
			OE_Breg 		= OE;
			WE_Breg 		= WE;
			load_Breg	= load;
			rs_Breg		= RESET;
		end
	end
	
	// Arithmetic Logic Unit
	always @(posedge CLK) 
	begin	
		if (sel == ALU)
		begin
			OE_ALU		= OE;
			OP				= {2'b0,SUB};	// Only Add/Subtract right now
		end
	end
	
	// Memory Address Register	
	always @(posedge CLK) 
	begin	
		if (sel == MAR)
		begin
			WE_MAR		= WE;
			load_MAR		= load;
			rs_MAR		= RESET;
		end
	end
	
	// EEPROM
	always @(posedge CLK) 
	begin	
		if (sel == MEM)
		begin
		 OE_EEPROM		= OE;
		 WE_EEPROM		= WE;
		 load_EEPROM	= load;
		 rs_EEPROM		= RESET;
		end
		
		// We need a way to know when we are done writing/reading from memory
		if (OE_EEPROM)
			I2C_ADDR <= 8'hA1;	// Read from EEPROM to BUS
		else
		if (WE_EEPROM)
			I2C_ADDR <= 8'hA0;	// Write to EEPROM
	end
	
	// BUS Inputs
	always @(posedge CLK) 
	begin	
		if (sel == BUS)
		begin
			load_Bus		= load;
			rs_Bus		= RESET;
		end
	end
	
	// Module inputs	
	always @(posedge CLK) 
	begin	
		// At the moment, we trust the user to not set multiple modules to write to the bus
		if (WE_PC)
			PC_in <= Bus_data[7:4]; 			// read 4 MSBs from bus
		else 
		if	(load_PC)	
			PC_in <= in[7:4];						// read from programmer

		if (WE_Acc)
			Acc_in <= Bus_data;
		else
		if	(load_Acc)
			Acc_in <= in;
		
		if (WE_Breg)	
			Breg_in <= Bus_data;
		else
		if	(load_Breg)	
			Breg_in <= in;
		
		if	(WE_MAR)		
			MAR_in <= Bus_data[7:4];
		else
		if	(load_MAR)	
			MAR_in <= in[7:4];
	end
	assign EEPROM_DATA = (WE_EEPROM)		? Bus_data	:
								(load_EEPROM)	? in		 	: 8'bz;	
	
	// BUS outputs
	always @* 
	begin	
		if 		(load_Bus)				Bus_data <= in;					// programming bus
		else if	(OE_PC)					Bus_data <= {PC_out,4'b0}; 	// output to bus
		else if	(OE_Acc)					Bus_data <= Acc_out;	
		else if	(OE_Breg)				Bus_data <= Breg_out;		
		else if	(OE_ALU)					Bus_data <= ALU_out;	
		else if 	(OE_EEPROM & DONE)	Bus_data <= EEPROM_DATA;		// Output EEPROM data once we have it all	
		else if	(rs_Bus)					Bus_data <= 8'b0;	
	end

	// Debounce
	always @(posedge CLK) begin	
		if (go_db != go)
			cnt <= 0;	// nothing happening
		else 
		begin
			cnt <= cnt + 16'd1;
			if (mcount) 
				go_db <= ~go_db;
		end					
	end
//		if (go_db == 1'b1)								//use go_db when using 50MHz clock, go for tb
//		begin						
//			case (sel)
//				PC		:	begin								// ProgramCounter
//								OE_PC			= OE;
//								WE_PC 		= WE;
//								load_PC		= load;
//								rs_PC			= RESET;
//							end
//				Acc	:	begin								// Accumulator
//								OE_Acc		= OE;
//								WE_Acc		= WE;
//								load_Acc		= load;
//								rs_Acc		= RESET;
//							end
//				Breg	:	begin								// B Register
//								OE_Breg 		= OE;
//								WE_Breg 		= WE;
//								load_Breg	= load;
//								rs_Breg		= RESET;
//							end
//				ALU	:	begin								// Arithmetic Logic Unit
//								OE_ALU		= OE;		
//							end
//				BUS	:	begin
//								load_Bus		= load;
//								rs_Bus		= RESET;
//							end
//				MAR	:	begin								// Memory Address Register
//								WE_MAR		= WE;
//								load_MAR		= load;
//								rs_MAR		= RESET;
//							end
//				MEM	:	begin
//								I2C_ADDR		<= (WE == 1'b1 || load == 1'b1)? WRITE:
//													((OE == 1'b1)? READ : 1'b0);
//								OE_EEPROM	<= OE;
//								WE_EEPROM	<= WE;
//								load_EEPROM <= load;
//								rs_EEPROM 	<= RESET;
//							end
//			endcase
//			$display("load_PC = %d",load_PC);
//		end
//		
//		 // We output to and read from bus and load on the next clock cycle
//		 // At the moment, we trust the user to not set multiple modules to write to the bus
//		if (WE_PC)
//			PC_in <= Bus_data[7:4]; 			// read 4 MSBs from bus
//		else 
//		if	(load_PC)	
//			PC_in <= in[7:4];					// read from programmer
//
//		if (WE_Acc)
//			Acc_in <= Bus_data;
//		else
//		if	(load_Acc)
//			Acc_in <= in;
//		
//		if (WE_Breg)	
//			Breg_in <= Bus_data;
//		else
//		if	(load_Breg)	
//			Breg_in <= in;
//		
//		if	(WE_MAR)		
//			MAR_in <= Bus_data[7:4];
//		else
//		if	(load_MAR)	
//			MAR_in <= in[7:4];
//		
//		
//		if (load_Bus)	Bus_data <= in;								// programming bus
//		if	(OE_PC)		Bus_data <= {PC_out,4'b0}; 			// output to bus
//		if	(OE_Acc)		Bus_data <= Acc_out;	
//		if	(OE_Breg)	Bus_data <= Breg_out;		
//		if	(OE_ALU)		Bus_data <= ALU_out;	
//		if (OE_EEPROM)	Bus_data <= EEPROM_DATA;	
//		if (rs_Bus)		Bus_data <= 8'b0;	
//	end
endmodule

	//assign EEPROM_DATA = ((I2C_ADDR == WRITE)? 
	//							((WE_EEPROM == 1'b1)? Bus_data : ((load_EEPROM == 1'b1)? in : 1'bz)):1'bz);