module AddSubtract	(output reg [7:0]ALU_out,
							 input wire [7:0]Acc_in,		// Accumulator input
							 input wire [7:0]Breg_in,		// B register input
							 input wire SUB,OE,CLK);		// Subtract,output enable,clock
			
	reg [7:0]TB; 
	reg [7:0]ALU_data;
		
	always @(ALU_out or Acc_in or Breg_in or SUB) begin
		TB = ~Breg_in+1;						// Two's complement for subtraction
		
		if (SUB) begin
			ALU_data <= Acc_in + $signed(TB);
		end else begin
			ALU_data <= Acc_in + Breg_in;
		end
	end
	
	always @(posedge CLK) begin
			if (OE) ALU_out <= ALU_data;			// output to bus
	end
endmodule