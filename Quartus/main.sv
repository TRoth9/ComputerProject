module main	(output reg [3:0]count,
				 output on,
				 input [3:0]sel, //select from 16 modules
				 input [7:0]in,
				 input CLK,RESET,
				 input en,go,		//go updates inputs for our selected module
				 input OE,WE,load,
				 input HLT,	//halt the PC
				 output [7:0]Bus_out,
				 input SUB);
				 
	//NOTE:	WE has priority over OE.
	//			RESET is synchronous	(asynchronous messes with our hierarchy, need to figure out why)
	//instantiate each module, but use muiltiplexer to change which module we select
	//We use one set of inputs of OE, WE (load), RESET, and store these values in D latches in each module
	//		We might not need D latches. We only want to WE when programming and OE when we want to see data in module
	//multiplexer selects which module, and enables the inputs for that specific module
	//		i.e.: program counter can be enPC		
		
	parameter 	PC 	=	4'b0000, //	ProgramCounter
					Acc 	= 	4'b0001,	//	Accumulator
					Breg 	= 	4'b0010,	//	B register
					ALU 	= 	4'b0011,	//	Arithmetic Logic Unit
					MAR 	= 	4'b0100,	//	Memory Address Register
					RAM 	= 	4'b0101,	//	Random Acess Memory
					IR 	=	4'b0110,	//	Instruction Register
					CNTRL = 	4'b0111,	//	Controller/Sequencer
					OR 	=	4'b1000,	//	Output Register
					BUS	=	4'b1001;	// Bus
	
	reg enPC,
		 OE_PC,WE_PC,load_PC,
		 OE_Acc,WE_Acc,load_Acc,
		 OE_Breg,WE_Breg,load_Breg,
		 OE_ALU,
		 WE_Bus,load_Bus;
	
	reg [7:0]Bus_data;
	
	reg [3:0]PC_out;
	reg [7:0]Breg_out;
	reg [7:0]Acc_out;
	reg [7:0]ALU_out;
	
	reg [3:0]PC_in;
	reg [7:0]Breg_in;
	reg [7:0]Acc_in;
	reg [7:0]Bus_in;
	
	reg [15:0]cnt;		//debounce vars
	reg go_db;
	wire mcount = &cnt;
	
	always @(go_db or sel or go or HLT) begin
		{enPC,OE_PC,WE_PC,load_PC} = 4'b1000;
		{OE_Acc,WE_Acc,load_Acc} = 3'b000;
		{OE_Breg,WE_Breg,load_Breg} = 3'b000;
		OE_ALU = 1'b0;
		{WE_Bus,load_Bus} = 3'b000;	

		if (go_db) begin									//use go_db when using 50MHz clock
			case (sel)
				PC		:	begin
								enPC			<= en;		//ProgramCounter
								OE_PC			<= OE;
								WE_PC 		<= WE;
								load_PC		<= load;
							end
				Acc	:	begin
								OE_Acc		<= OE;
								WE_Acc		<= WE;		// Accumulator
								load_Acc		<= load;
							end
				Breg	:	begin
								OE_Breg 		<= OE;
								WE_Breg 		<= WE;		// B Register
								load_Breg	<= load;
							end
				ALU	:	begin
								OE_ALU		<= OE;		
							end
				BUS	:	begin
								WE_Bus 		<= WE;
								load_Bus		<= load;
							end
			endcase
		end
		else if (HLT) begin
			//Disable everything, counter stopped
			{enPC,OE_PC,WE_PC,load_PC} <= 4'b0000;
			{OE_Acc,WE_Acc,load_Acc} <= 3'b000;
			{OE_Breg,WE_Breg,load_Breg} <= 3'b000;
			OE_ALU <= 1'b0;
			{OE_Bus,WE_Bus,load_Bus} <= 3'b000;
		end	
	end
	
	always @(posedge CLK) begin	
		if (go_db == go) cnt <= 0;
		else begin
			cnt <= cnt+1;
			if (mcount) go_db <= ~go_db;
		end
		
		// At the moment, we trust the user to not set multiple modules to write to the bus
		if 		(WE_PC)		PC_in = Bus_data[7:4]; 			// read 4 MSBs from bus
		else if	(OE_PC)		Bus_data = {PC_out,4'b0000}; 	// output to bus
		else if	(load_PC)	PC_in = in[7:4];					// read from programmer
		
		if 		(WE_Acc)		Acc_in = Bus_data;
		else if	(OE_Acc)		Bus_data = Acc_out;
		else if	(load_Acc)	Acc_in = in;
		
		if 		(WE_Breg)	Breg_in = Bus_data;
		else if	(OE_Breg)	Bus_data = Breg_out;
		else if	(load_Breg)	Breg_in = in;
		
		if 		(load_Bus)				Bus_in = in;			// programming bus
		else if	(Bus_in != Bus_data)	Bus_in = Bus_data;	// outputting module data
	end
		
	ProgramCounter ProgramCounter_1 (
			.counter	( count	),
			.PC_out	( PC_out	),
			.on		( on		),
			.PC_in	( PC_in	),
			.CLK		( CLK		),
			.RESET	( RESET	),
			.WE		( WE_PC	),
			.OE		( OE_PC	),
			.en		( enPC	) //enables counter
	);
												
	Accumulator	Accumulator_1	(
			.Acc_out		( Acc_out	),
			.Acc_in		( Acc_in		),
			.OE			( OE_Acc		),
			.WE			( WE_Acc		),
			.load			( load_Acc	),
			.CLK			( CLK			),
			.RESET		( RESET		)
	);
										 
	BRegister	Breg_1	(
			.Breg_out	( Breg_out	),
			.Breg_in		( Breg_in	),
			.OE			( OE_Breg	),
			.WE			( WE_Breg	),
			.load			( load_Breg	),
			.CLK			( CLK			),
			.RESET		( RESET		)
	);			

	AddSubtract AddSubtract_1 (
			.ALU_out	( ALU_out	),
			.Acc_in	( Acc_in		),
			.Breg_in	( Breg_in	),
			.OE		( OE_ALU		),
			.SUB		( SUB			),
			.CLK		( CLK			)
	);
										
	BUS Bus_1	(
			.Bus_out		( Bus_out	),
			.Bus_in		( Bus_data	),
			.WE			( WE_Bus		)
	);
endmodule