module OP_REG	(
	output reg	[6:0] OR_OUT,
	output reg	[3:0]	ANODE,
	input 		[7:0] OR_IN,
	input					WE,
	input					PRGM,
	input 				CLK,
	input					RESET
);
		
reg [1:0]	CNT = 0;
reg [6:0]	OR_DATA;

always @(posedge CLK)
begin
	CNT <= CNT +1;
	
	// Activate 7-seg anodes
	case (CNT)
		2'd0:	begin
					ANODE <= 4'b0001;
					OR_DATA <= OR_IN / 1000;
				end
		2'd1:	begin
					ANODE <= 4'b0010;
					OR_DATA <= (OR_IN % 1000) / 100;
				end
		2'd2:	begin
					ANODE <= 4'b0100;
					OR_DATA <= ((OR_IN % 1000) % 100) / 10;
				end
		2'd3:	begin
					ANODE <= 4'b1000;
					OR_DATA <= ((OR_IN % 1000) % 100) % 10;
				end
		default:	CNT <= 0;
	endcase
end

always @(posedge CLK or posedge RESET) begin
		if (RESET) begin
			OR_OUT = 7'b0000000;
		end					
		else if (WE || PRGM) 
		begin
			// 7 segment decoder
			case (OR_DATA)
				8'd0:	OR_OUT <= 7'b1111110;
				8'd1: OR_OUT <= 7'b0110000;
				8'd2: OR_OUT <= 7'b1101101;
				8'd3: OR_OUT <= 7'b1111001;
				8'd4: OR_OUT <= 7'b0110011;
				8'd5: OR_OUT <= 7'b1011011;
				8'd6: OR_OUT <= 7'b1011111;
				8'd7: OR_OUT <= 7'b1110000;
				8'd8: OR_OUT <= 7'b1111111;
				8'd9: OR_OUT <= 7'b1111011;
				8'd10: OR_OUT <= 7'b1110111;
				8'd11: OR_OUT <= 7'b0011111;
				8'd12: OR_OUT <= 7'b1001110;
				8'd13: OR_OUT <= 7'b0111101;
				8'd14: OR_OUT <= 7'b1001111;
				8'd15: OR_OUT <= 7'b1000111;
				default: OR_OUT <= 7'b1111110;
			endcase
		end
end

endmodule