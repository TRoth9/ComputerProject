module main	(
	output 	[3:0]count,
	output	[3:0]Address,
	output	[7:0]Bus_out,
	output	[7:0]Mem_out,
	output	reg[7:0]curr,
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
		
	parameter 	PC 	=	4'b0000, //	ProgramCounter
					Acc 	= 	4'b0001,	//	Accumulator
					Breg 	= 	4'b0010,	//	B register
					ALU 	= 	4'b0011,	//	Arithmetic Logic Unit
					MAR 	= 	4'b0100,	//	Memory Address Register
					Mem 	= 	4'b0101,	//	SDRAM on De0-nano
					IR 	=	4'b0110,	//	Instruction Register
					CNTRL = 	4'b0111,	//	Controller/Sequencer
					OR 	=	4'b1000,	//	Output Register
					BUS	=	4'b1001;	// Bus
	
	logic OE_PC,WE_PC,load_PC,rs_PC,
		 OE_Acc,WE_Acc,load_Acc,rs_Acc,
		 OE_Breg,WE_Breg,load_Breg,rs_Breg,
		 OE_Mem,WE_Mem,load_Mem,rs_Mem,
		 WE_MAR,load_MAR,rs_MAR,
		 OE_ALU,
		 load_Bus,rs_Bus;
	
	reg [7:0]Mem_data;
	reg [7:0]Bus_data;
	
	reg [3:0]PC_out;
	reg [3:0]MAR_out;
	reg [7:0]Breg_out;
	reg [7:0]Acc_out;
	reg [7:0]ALU_out;
	//reg [7:0]Mem_out;

	reg [3:0]PC_in;
	reg [3:0]MAR_in;
	reg [7:0]Mem_in;
	reg [7:0]Breg_in;
	reg [7:0]Acc_in;
	reg [7:0]Bus_in;
	
	reg [15:0]cnt;		//debounce vars
	reg go_db;
	wire mcount = &cnt;
	
	wire en_PC = en & ~HLT;
	
	ProgramCounter ProgramCounter_1 (
			.count	( count	),
			.PC_out	( PC_out	),
			.on		( on		),
			.PC_in	( PC_in	),
			.CLK		( CLK		),
			.RESET	( rs_PC	),
			.load		( load_PC),
			.WE		( WE_PC	),
			.OE		( OE_PC	),
			.en		( en_PC	) //enables counter
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

	AddSubtract AddSubtract_1 (
			.ALU_out	( ALU_out	),
			.Acc_in	( Acc_in		),
			.Breg_in	( Breg_in	),
			.OE		( OE_ALU		),
			.SUB		( SUB			),
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
	
	Mem Mem_1	(
			.Mem_out		( Mem_out	),
			.Mem_in		( Mem_in		),
			.Address		( MAR_out	),
			.OE			( OE_Mem		),
			.WE			( WE_Mem		),
			.load			( load_Mem	),
			.CLK			( CLK			),
			.RESET		( rs_Mem		)
	);
										
	BUS Bus_1	(
			.Bus_out		( Bus_out	),
			.Bus_in		( Bus_data	),
			.CLK			( CLK			),
			.RESET		( rs_Bus		)
	);
	
	always @(sel) begin
			curr = 8'b0000000;
			case (sel)
			PC		:	begin								//ProgramCounter
							curr = PC_out;
						end
			Acc	:	begin								// Accumulator
							curr = Acc_out;
						end
			Breg	:	begin								// B Register
							curr = Breg_out;
						end
			ALU	:	begin	
							curr = ALU_out;
						end
			MAR	: 	begin
							curr = MAR_out;
						end
			Mem	: 	begin
							curr = Mem_out;
						end
		endcase
	end
	
	always @(posedge CLK) begin	
		if (go_db != go) cnt <= 0;	// nothing happening
		else begin
			cnt <= cnt + 16'd1;
			if (mcount) go_db <= ~go_db;
		end

		if (go_db) begin									//use go_db when using 50MHz clock, go for tb
			case (sel)
				PC		:	begin								//ProgramCounter
								OE_PC			= OE;
								WE_PC 		= WE;
								load_PC		= load;
								rs_PC			= RESET;
							end
				Acc	:	begin								// Accumulator
								OE_Acc		= OE;
								WE_Acc		= WE;
								load_Acc		= load;
								rs_Acc		= RESET;
							end
				Breg	:	begin								// B Register
								OE_Breg 		= OE;
								WE_Breg 		= WE;
								load_Breg	= load;
								rs_Breg		= RESET;
							end
				ALU	:	begin								// Arithmetic Logic Unit
								OE_ALU		= OE;		
							end
				BUS	:	begin
								load_Bus		= load;
								rs_Bus		= RESET;
							end
				MAR	:	begin								// Memory Address Register
								WE_MAR		= WE;
								load_MAR		= load;
								rs_MAR		= RESET;
							end
				Mem	:	begin								// SDRam on dev board
								OE_Mem		= OE;
								WE_Mem		= WE;
								load_Mem		= load;
								rs_Mem		= RESET;
							end
			endcase
			$display("load_PC = %d",load_PC);
		end
		else if (HLT) begin
			//Disable everything,
			{OE_PC,WE_PC,load_PC} = 3'b000; //counter stopped
			{OE_Acc,WE_Acc,load_Acc} = 3'b000;
			{OE_Breg,WE_Breg,load_Breg} = 3'b000;
			OE_ALU = 1'b0;
			{load_Bus} = 3'b000;
		end	
		
		
		//We output to and read from bus and load on the next clock cycle
		// At the moment, we trust the user to not set multiple modules to write to the bus
		if 		(WE_PC)		PC_in = Bus_data[7:4]; 			// read 4 MSBs from bus
		else if	(load_PC)	PC_in = in[7:4];					// read from programmer

		if 		(WE_Acc)		Acc_in = Bus_data;
		else if	(load_Acc)	Acc_in = in;
		
		if 		(WE_Breg)	Breg_in = Bus_data;
		else if	(load_Breg)	Breg_in = in;
		
		if 		(WE_Mem)		Mem_in = Bus_data;
		else if	(load_Breg)	Mem_in = in;
		
		if (load_Bus)	Bus_data = in;								// programming bus
		if	(OE_PC)		Bus_data = {PC_out,4'b0000}; 			// output to bus
		if	(OE_Acc)		Bus_data = Acc_out;	
		if	(OE_Breg)	Bus_data = Breg_out;		
		if	(OE_ALU)		Bus_data = ALU_out;	
		if (OE_Mem)		Bus_data = Mem_out;

		
		//$monitor("PC = %d",count);
	end

endmodule