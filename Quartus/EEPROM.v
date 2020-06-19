module EEPROM	(
		output 				I2C_SCLK,
		inout			[7:0]	EEPROM_DATA,
		inout	 				I2C_SDAT,
		input			[7:0]	I2C_ADDR,					// I2C Address
		input			[3:0]	WORD_ADDR,
		input					GO_DB,						// go_db from top level
		input					CLK,
		input					RESET
	);
		
		reg			GO;							// Initialize EEPROM counter
		reg			SDI;							// Slave device input
		reg			SCLK;							
		reg	[9:0]	CLK_COUNT,					// EEPROM Clock
		reg	[5:0] SD_COUNTER;					// Counter for EEPROM
		reg	[5:0]	PULSE_COUNT;				// How many I2C_SCLK pulses for operation
		reg	[7:0]	R_DATA;						// EEPROM data from read operation
					
		parameter	WRITE = 8'hA0,				// EEPROM Addresses
						READ	= 8'hA1;
		
		// Setup clock for EEPROM
		always @(posedge CLK) CLK_COUNT <= CLK_COUNT + 1;
		
		always @(posedge CLK)
		begin
			if (I2C_ADDR == WRITE)
				PULSE_COUNT <= 32;
			else
			if (I2C_ADDR == READ)
			begin
				PULSE_COUNT <= 42;
			end
		end
		
		// Initialize EEPROM Counter
		always @(posedge CLK_COUNT[9] or posedge RESET) 
		begin
			if (RESET)
				GO <= 1'b0;
			else 
				if (GO_DB)
					GO <= 1'b1;
		end
		
		// EEPROM Counter
		always @(posedge CLK_COUNT[9] or posedge RESET) 
		begin
			if (RESET)
				SD_COUNTER <= 1'b0;
			else
			begin
				if (!GO)
					SD_COUNTER <= 1'b0;
				else
					if (SD_COUNTER <= PULSE_COUNT+1)					// Write takes 33 I2C clock pulses
						SD_COUNTER <= SD_COUNTER + 1;
			end
		end
		
		always @(posedge CLK_COUNT[9] or posedge RESET) 
		begin
			if (RESET)
			begin
				SCLK	<= 1'b1;
				SDI	<= 1'b1;
			end
			else 
			if (I2C_ADDR == WRITE)										// WRITE
			begin
				case	(SD_COUNTER)					
					6'd0	:	begin
									SDI	<= 1'b1;
									SCLK	<= 1'b1;
								end
					
					// START
					6'd1	:		SDI	<= 1'b0;
					6'd2	:		SCLK	<= 1'b0;
					
					// Write Control Bite
					6'd3	:		SDI	<= 1'b1;
					6'd4	:		SDI	<= 1'b0;
					6'd5	:		SDI	<= 1'b1;
					6'd6	:		SDI	<= 1'b0;
					6'd7	:		SDI	<= 1'b0;
					6'd8	:		SDI	<= 1'b0;
					6'd9	:		SDI	<= 1'b0;
					6'd10	:		SDI	<= 1'b0;
					6'd11	:		SDI	<= 1'bz;	// ACK
					
					// Word Address
					6'd12	:		SDI	<= WORD_ADDR[0];
					6'd13	:		SDI	<= WORD_ADDR[1];
					6'd14	:		SDI	<= WORD_ADDR[2];
					6'd15	:		SDI	<= WORD_ADDR[3];
					6'd16	:		SDI	<= 1'b0;
					6'd17	:		SDI	<= 1'b0;
					6'd18	:		SDI	<= 1'b0;
					6'd19	:		SDI	<= 1'b0;
					6'd20	:		SDI	<= 1'bz;	// ACK
					
					// Data
					6'd21	:		SDI	<= EEPROM_DATA[0];
					6'd22	:		SDI	<= EEPROM_DATA[1];
					6'd23	:		SDI	<= EEPROM_DATA[2];
					6'd24	:		SDI	<= EEPROM_DATA[3];
					6'd25	:		SDI	<= EEPROM_DATA[4];
					6'd26	:		SDI	<= EEPROM_DATA[5];
					6'd27	:		SDI	<= EEPROM_DATA[6];
					6'd28	:		SDI	<= EEPROM_DATA[7];
					6'd29	:		SDI	<= 1'bz;	// ACK
					
					// STOP
					6'd30	:	begin
									SDI	<= 1'b0;
									SCLK	<= 1'b1;
								end
					6'd31	:		SDI	<= 1'b1;
				endcase
			end
			else 
			if (I2C_ADDR == READ)									// READ 
			begin
				case	(SD_COUNTER)
					6'd0	:	begin
									SDI	<= 1'b1;
									SCLK	<= 1'b1;
								end
					
					// START
					6'd1	:		SDI	<= 1'b0;
					6'd2	:		SCLK	<= 1'b0;
										
					// Write Control Byte
					6'd3	:		SDI	<= 1'b1;
					6'd4	:		SDI	<= 1'b0;
					6'd5	:		SDI	<= 1'b1;
					6'd6	:		SDI	<= 1'b0;
					6'd7	:		SDI	<= 1'b0;
					6'd8	:		SDI	<= 1'b0;
					6'd9	:		SDI	<= 1'b0;
					6'd10	:		SDI	<= 1'b0;
					6'd11	:		SDI	<= 1'bz;	// ACK
					
					// Word Address
					6'd12	:		SDI	<= WORD_ADDR[0];
					6'd13	:		SDI	<= WORD_ADDR[1];
					6'd14	:		SDI	<= WORD_ADDR[2];
					6'd15	:		SDI	<= WORD_ADDR[3];
					6'd16	:		SDI	<= 1'b0;
					6'd17	:		SDI	<= 1'b0;
					6'd18	:		SDI	<= 1'b0;
					6'd19	:		SDI	<= 1'b0;
					6'd20	:		SDI	<= 1'bz;	// ACK
					
					// START
					6'd21	:		SDI	<= 1'b0;
					6'd22	:		SCLK	<= 1'b0;
										
					// Read Control Byte
					6'd23	:		SDI	<= 1'b1;
					6'd24	:		SDI	<= 1'b0;
					6'd25	:		SDI	<= 1'b1;
					6'd26	:		SDI	<= 1'b0;
					6'd27	:		SDI	<= 1'b0;
					6'd28	:		SDI	<= 1'b0;
					6'd29	:		SDI	<= 1'b0;
					6'd30	:		SDI	<= 1'b1;
					6'd31	:		SDI	<= 1'bz;	// ACK
					
					// Data
					6'd32	:		R_DATA[0] <= I2C_SDAT;
					6'd33	:		R_DATA[1] <= I2C_SDAT;
					6'd34	:		R_DATA[2] <= I2C_SDAT;
					6'd35	:		R_DATA[3] <= I2C_SDAT;
					6'd36	:		R_DATA[4] <= I2C_SDAT;
					6'd37	:		R_DATA[5] <= I2C_SDAT;
					6'd38	:		R_DATA[6] <= I2C_SDAT;
					6'd39	:		R_DATA[7] <= I2C_SDAT;
					// No ACK
					
					// STOP
					6'd40	:	begin
									SDI	<= 1'b0;
									SCLK	<= 1'b1;
								end
					6'd41	:		SDI	<= 1'b1;
				endcase
			end
		end
		
		assign I2C_SCLK = ((I2C_ADDR == WRITE)? ((SD_COUNTER >= 4) & (SD_COUNTER <= 31) ? ~CLK_COUNT[9] : SCLK):
															((SD_COUNTER >= 4) & (SD_COUNTER <= 23)) ? ~CLK_COUNT[9] :
															((SD_COUNTER >= 24) & (SD_COUNTER <= 41) ? ~CLK_COUNT[9] : SCLK));
		assign I2C_SDAT = (I2C_ADDR == WRITE)? SDI : 1'bz;
		assign EEPROM_DATA = (I2C_ADDR == READ)? R_DATA : 1'bz;
endmodule