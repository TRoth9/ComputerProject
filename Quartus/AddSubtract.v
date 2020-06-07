module AddSubtract	(output reg [7:0]A_out,
							 output reg c_out,
							 input wire [7:0] A_in,
							 input wire [7:0] B_in,
							 input wire SUB,
							 input wire OE);	//output enable
			
	reg [7:0] TB; 
	reg qOE;
	
	always @(A_out or A_in or B_in or SUB) begin
		if (OE) begin
			if (SUB) begin
				TB <= ~B_in+1;
				A_out <= A_in + $signed(TB);
				c_out <= A_in[7] + TB[7];
			end else begin
				A_out <= A_in + B_in;
				c_out <= A_in[7] + B_in[7];
			end
		end
	end
	
	always @(posedge CLK) begin
		//We need D latches to store OE WE, etc...and we need to debounce (lab 4)
		qOE <= OE;
	end

endmodule