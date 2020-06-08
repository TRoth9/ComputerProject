module main	(output reg [3:0]count,
				 output on,
				 input [3:0]sel, //select from 16 modules
				 input [7:0]in,
				 input CLK,RESET,
				 input en,go,		//go updates inputs for our selected module
				 input OE,WE,
				 input HLT,	//halt the PC
				 output [7:0]Bus_out,
				 output reg c_out,
				 input SUB);
	//instantiate each module, but use muiltiplexer to change which module we select
	//We use one set of inputs of OE, WE (load), RESET, and store these values in D latches in each module
	//		We might not need D latches. We only want to WE when programming and OE when we want to see data in module
	//multiplexer selects which module, and enables the inputs for that specific module
	//		i.e.: program counter can be enPC		
		
	//make sure we debounce each input as they are coming from breadboard (re: lab 4)
	
	parameter 	PC 	=	4'b0000, //	ProgramCounter
					Acc 	= 	4'b0001,	//	Accumulator
					Breg 	= 	4'b0010,	//	B register
					ALU 	= 	4'b0011,	//	Arithmetic Logic Unit
					MAR 	= 	4'b0100,	//	Memory Address Register
					RAM 	= 	4'b0101,	//	Random Acess Memory
					IR 	=	4'b0110,	//	Instruction Register
					CNTRL = 	4'b0111,	//	Controller/Sequencer
					OR 	=	4'b1000;	//	Output Register
	
	reg enPC,
		 OE_PC,WE_PC,
		 OE_Acc,WE_Acc,
		 OE_Breg,WE_Breg,
		 OE_ALU;
	
	reg [7:0]Bus_data;
	
	reg [3:0]PC_out;
	reg [7:0]B_out;
	reg [7:0]Acc_out;
	
	reg [3:0]PC_in;
	reg [7:0]B_in;
	reg [7:0]Acc_in;
	
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
		
		if (go_db & !HLT) begin							//debounced go
			case (sel)
				PC	:		begin
								enPC <= en;			//ProgramCounter, set enPC ACTIVE
								OE_PC <= OE;
								WE_PC <= WE;
							end
				Acc	:	begin
								OE_Acc <= OE;
								WE_Acc <= WE;		//Accumulator
							end
				Breg	:	begin
								OE_Breg <= OE;
								WE_Breg <= WE;		//B Register
							end
				ALU	:	begin
								OE_ALU <= OE;		//ALU
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
	
		if (WE_PC) begin				//read from bus
			PC_in <= Bus_data[7:4];
		end else if (OE_PC) begin	//output to bus
			Bus_data <= {PC_out,4'b0000}; //PC only outputs 4 MSBs, rest set INACTIVE
		end
		
		if (WE_Acc) begin
			Acc_in <= Bus_data;
		end else if (OE_Acc) begin
			Bus_data <= Acc_out;
		end
		
		if (WE_Breg) begin
			B_in <= Bus_data;
		end else if (OE_Acc) begin
			Bus_data <= B_out;
		end
	end
	
	assign Bus_out = Bus_data;
	
	ProgramCounter ProgramCounter_1 (.counter	( count	),
												.PC_out	( PC_out	),
												.on		( on		),
												.in		( PC_in	),
												.CLK		( CLK		),
												.RESET	( RESET	),
												.WE		( WE_PC	),
												.OE		( OE_PC	),
												.en		( enPC	)); //enables counter

	AddSubtract AddSubtract_1 (.A_out	( Acc_out	),
										.c_out	( c_out		),
										.A_in		( Acc_in		),
										.B_in		( B_in		),
										.SUB		( SUB			));
endmodule