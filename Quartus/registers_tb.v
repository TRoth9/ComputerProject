`timescale 1ns			/100ps
module registers_tb();
	wire 	[3:0]count;
	wire	[7:0]Bus_out;
	wire 	[7:0]curr;
	wire	on;
	reg 	[3:0]sel; //select from 16 modules
	reg 	[7:0]in;
	reg 	CLK,RESET;
	reg 	en,go;		//go updates regs for our selected module
	reg 	OE,WE,load;
	reg 	HLT;	//halt the PC
	reg 	SUB;

	main uut(
				.count	(count),
				.Bus_out	(Bus_out),
				.on		(on),
				.sel		(sel),
				.in		(in),
				.CLK		(CLK),
				.RESET	(RESET),
				.en		(en),
				.go		(go),
				.OE		(OE),
				.WE		(WE),
				.load		(load),
				.HLT		(HLT),
				.SUB		(SUB),
				.curr		(curr)
				);
	
	initial begin
		CLK = 1'b0;
		RESET = 1'b0;
		sel = 4'b000;
		in = 8'b00000000;
		en = 1'b0;
		go = 1'b0;
		OE = 1'b0;
		WE = 1'b0;
		load = 1'b0;
		HLT = 1'b0;
		SUB = 1'b0;
		#25;
		
		RESET = 1'b1;				// reset PC
		sel = 4'b1001;
		go = 1'b1;
		#50;
		
		RESET = 1'b0;
		go = 1'b0;
		in = 8'b10101010;
		load = 1'b1;
		OE = 1'b1;
		
		#50;
		go = 1'b1;
		
		#100;
		load = 1'b0;
		go = 1'b0;
		OE = 1'b0;
	end

	always begin
		#50;
		CLK = ~CLK;
	end

endmodule