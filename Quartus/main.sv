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
	//			RESET is synchronous	(asynchronous messes with our hierarchy)
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
		 OE_Bus,WE_Bus,load_Bus;
	
	reg [7:0]Bus_data;
	
	reg [3:0]PC_out;
	reg [7:0]Breg_out;
	reg [7:0]Acc_out;
	reg [7:0]ALU_out;
	
	reg [3:0]PC_in;
	reg [7:0]Breg_in;
	reg [7:0]Acc_in;
	reg [7:0]Bus_in;
	
	reg [15:0]cnt;		//deboumce vars
	reg go_db;
	wire mcount = &cnt;
	
	always @(sel or go or HLT) begin
		if (HLT) begin
			//Disable everything, counter stopped
			{enPC,OE_PC,WE_PC} <= 3'b000;
			{OE_Acc,WE_Acc} <= 2'b00;
			{OE_Breg,WE_Breg} <= 2'b00;
			OE_ALU <= 1'b0;
		end
		
		if (go_db & ~HLT) begin							//debounced go
			case (sel)
				PC	:		begin
								enPC			<= en;		//ProgramCounter, set enPC ACTIVE
								OE_PC			<= OE;
								WE_PC 		<= WE & ~load;
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
	end

	always @(posedge CLK) begin
		if (go_db != go) cnt <= 0;
		else begin
			cnt <= cnt+1;
			if (mcount) go_db <= ~go_db;
		end
	
		// At the moment, we trust the user to not set multiple modules to write to the bus
		if (WE_PC) begin						// read from bus
			PC_in <= Bus_data[7:4];
		end
		else if (OE_PC) begin				// output to bus
			Bus_data <= {PC_out,4'b0000}; // PC only outputs 4 MSBs, rest set INACTIVE
		end 
		else if (load_PC) begin
			PC_in <= in[7:4];					// read from programmer
		end
		
		if (WE_Acc) begin
			Acc_in <= Bus_data;
		end 
		else if (OE_Acc) begin
			Bus_data <= Acc_out;
		end 
		else if (load_Acc) begin
			Acc_in <= in;
		end
		
		if (WE_Breg) begin
			Breg_in <= Bus_data;
		end 
		else if (OE_Breg) begin
			Bus_data <= Breg_out;
		end
		else if (load_Breg) begin
			Breg_in <= in;
		end
	end
	
	assign Bus_out = Bus_data;
	
	ProgramCounter ProgramCounter_1 (.counter	( count	),
												.PC_out	( PC_out	),
												.on		( on		),
												.PC_in	( PC_in	),
												.CLK		( CLK		),
												.RESET	( RESET	),
												.WE		( WE_PC	),
												.OE		( OE_PC	),
												.en		( enPC	)); //enables counter
												
	Accumulator	Accumulator_1	(.Acc_out	( Acc_out	),
										 .Acc_in		( Acc_in		),
										 .OE			( OE_Acc		),
										 .WE			( WE_Acc		),
										 .load		( load_Acc	),
										 .CLK			( CLK			),
										 .RESET		( RESET		));
										 
	BRegister	Breg_1	(.Breg_out	( Breg_out	),
								 .Breg_in	( Breg_in	),
								 .OE			( OE_Breg	),
								 .WE			( WE_Breg	),
								 .load		( load_Breg	),
								 .CLK			( CLK			),
								 .RESET		( RESET		));			

	AddSubtract AddSubtract_1 (.ALU_out	( ALU_out	),
										.Acc_in	( Acc_in		),
										.Breg_in	( Breg_in	),
										.OE		( OE_ALU		),
										.SUB		( SUB			));
										
	BUS Bus_1	(.Bus_in		( Bus_in		),
					 .OE			( OE_Bus		),
					 .WE			( WE_Bus		));
endmodule