module main	(
	output 	[3:0]count,
	output 	[7:0]Bus_out,
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
					RAM 	= 	4'b0101,	//	Random Acess Memory
					IR 	=	4'b0110,	//	Instruction Register
					CNTRL = 	4'b0111,	//	Controller/Sequencer
					OR 	=	4'b1000,	//	Output Register
					BUS	=	4'b1001;	// Bus
	
	logic enPC,
		 OE_PC,WE_PC,load_PC,rs_PC,
		 OE_Acc,WE_Acc,load_Acc,rs_Acc,
		 OE_Breg,WE_Breg,load_Breg,rs_Breg,
		 OE_ALU,
		 load_Bus,rs_Bus;
	
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
			.en		( enPC	) //enables counter
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
										 
	BRegister	Breg_1	(
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
										
	BUS Bus_1	(
			.Bus_out		( Bus_out	),
			.Bus_in		( Bus_data	),
			.CLK			( CLK			),
			.RESET		( rs_Bus		)
	);
	
	always @(go or HLT or en or OE or WE or load or RESET) begin
//		{enPC,OE_PC,WE_PC,load_PC,rs_PC} = 5'b00000;
//		{OE_Acc,WE_Acc,load_Acc,rs_Acc} = 4'b0000;
//		{OE_Breg,WE_Breg,load_Breg,rs_Breg} = 4'b0000;
//		OE_ALU = 1'b0;
//		{load_Bus,rs_Bus} = 2'b00;	
		$display("sensitivity triggered");
		if (go) begin									//use go_db when using 50MHz clock
			case (sel)
				PC		:	begin								//ProgramCounter
								enPC			= en;		
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
				ALU	:	begin
								OE_ALU		= OE;		
							end
				BUS	:	begin
								load_Bus		= load;
								rs_Bus		= RESET;
							end
			endcase
			$display("load_PC = %d",load_PC);

		end
		else if (HLT) begin
			//Disable everything, counter stopped
			{enPC,OE_PC,WE_PC,load_PC} = 4'b0000;
			{OE_Acc,WE_Acc,load_Acc} = 3'b000;
			{OE_Breg,WE_Breg,load_Breg} = 3'b000;
			OE_ALU = 1'b0;
			{load_Bus} = 3'b000;
		end	
		
		//We output to and read from bus and load on the next clock cycle
		// At the moment, we trust the user to not set multiple modules to write to the bus
		if 		(WE_PC)		PC_in = Bus_data[7:4]; 			// read 4 MSBs from bus
		else if	(load_PC)	PC_in = in[7:4];					// read from programmer
		if	(OE_PC)				Bus_data = {PC_out,4'b0000}; 			// output to bus

		if 		(WE_Acc)		Acc_in = Bus_data;
		else if	(load_Acc)	Acc_in = in;
		if	(OE_Acc)		Bus_data = Acc_out;
		
		if 		(WE_Breg)	Breg_in = Bus_data;
		else if	(load_Breg)	Breg_in = in;
		if	(OE_Breg)	Bus_data = Breg_out;
		
		if 		(load_Bus)				Bus_in = in;			// programming bus
		else if	(Bus_in != Bus_data)	Bus_in = Bus_data;	// outputting module data
		
		$display("in[7:4] = %b",in[7:4]);
		$display("and PC_in = %b",PC_in);
		$display("and Bus_data = %b",Bus_data);
	end
	
	always @(posedge CLK) begin	
		if (go_db == go) cnt <= 0;
		else begin
			cnt <= cnt+1;
			if (mcount) go_db <= ~go_db;
		end
		

		
		//$monitor("PC = %d",count);
	end

endmodule