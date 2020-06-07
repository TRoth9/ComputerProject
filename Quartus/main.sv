module main	(output reg [3:0]count,
				 output on,
				 input [3:0]in,
				 input CLK,RESET,load,en,
				 input HLT;	//halt the PC
				 output reg [7:0]A_out,
				 output reg c_out,
				 input [7:0]A_in,
				 input [7:0]B_in,
				 input SUB);
	//instantiate each module, but use muiltiplexer to change which module we select
	//We use one set of inputs of OE, WE (load), RESET, and store these values in D latches in each module
	//multiplexer selects which module, and enables the inputs for that specific module
	//		i.e.: program counter can be enPC OE_PC, WE_PC,etc...
	
	ProgramCounter ProgramCounter_1 (.counter	( count	),
												.on		( on		),
												.in		( in		),
												.CLK		( CLK		),
												.RESET	( RESET	),
												.load		( load	),
												.en		( en		));

	AddSubtract AddSubtract_1 (.A_out	( A_out	),
										.c_out	( c_out	),
										.A_in		( A_in	),
										.B_in		( B_in	),
										.SUB		( SUB		));
endmodule