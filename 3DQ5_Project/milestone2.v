`ifndef DISABLE_DEFAULT_NET
`timescale 1ns/100ps
`default_nettype none
`endif
`include "define_state.h"

//mulitplier module which we will instantiate 3 times 
module Multiplier (
	input int op1, op2,
	output int out
);

	logic [63:0] Mult_result_long;
	assign Mult_result_long = op1 * op2;
	assign out = Mult_result_long[31:0];

endmodule

module milestone2(
	input logic CLOCK_50_I,
	input logic Resetn,
	input logic m2_start,
	input logic [15:0] SRAM_read_data,
	output logic [15:0] SRAM_write_data,
	output logic [17:0] SRAM_address,
	output logic write_en_n,
	output logic m2_finish
);

m2_state_type m2_state;

//all math on 32 bit signed
logic signed [31:0] m1_op1;
logic signed [31:0] m1_op2;
logic signed [31:0] m2_op1;
logic signed [31:0] m2_op2;
logic signed [31:0] m1_out;
logic signed [31:0] m2_out;

Multiplier mult1(
	.op1(m1_op1),
	.op2(m1_op2),
	.out(m1_out)
);

Multiplier mult2(
	.op1(m2_op1),
	.op2(m2_op2),
	.out(m2_out)
);

/* 
// RAM for storing Char ROM code
dual_port_RAM dual_port_RAM_inst (
	.address_a ( write_address ),
	.address_b ( read_address ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data ),
	.data_b ( 6'h00 ),
	.wren_a ( write_enable ),
	.wren_b ( 1'b0 ),
	.q_a (),
	.q_b ( character_address )
	);
	
*/

logic [17:0] address0;
logic [31:0] data_in0;
logic write_en0;
logic [31:0] data_out0;

logic [17:0] address1;
logic [31:0] data_in1;
logic write_en1;
logic [31:0] data_out1;

logic [17:0] address2;
logic [31:0] data_in2;
logic write_en2;
logic [31:0] data_out2;

logic [17:0] address3;
logic [31:0] data_in3;
logic write_en3;
logic [31:0] data_out3;

//instintiate DP-RAM1 
dual_port_RAM dual_port_RAM_inst (
	.address_a (address0),
	.address_b (address1),
	.clock (CLOCK_50_I),
	.data_a (data_in0),
	.data_b (data_in1),
	.wren_a (write_en0),
	.wren_b (write_en1),
	.q_a (data_out0),
	.q_b (data_out1)
	);
)

//instintiate DP-RAM2 
dual_port_RAM dual_port_RAM_inst (
	.address_a (address2),
	.address_b (address3),
	.clock (CLOCK_50_I),
	.data_a (data_in2),
	.data_b (data_in3),
	.wren_a (write_en2),
	.wren_b (write_en3),
	.q_a (data_out2),
	.q_b (data_out3)
	);
)


parameter pre_IDCT_Y = 18'd76800,
		  pre_IDCT_U = 18'd153600,
		  pre_IDCT_V = 18'd192000,
		  u_offset = 18'd38400,
		  v_offset = 18'd57600,
		  
;


logic [7:0] S; // output is 8 bit unsigned
logic [2:0] current_row_counter; //8 rows of data per 8x8 block of pre-IDCT data
logic [2:0] current_column_counter; //8 columns of data per 8x8 block of pre-IDCT data
logic [5:0] block_col; //the column location of the 8x8 block we are reading 
logic [4:0] block_row; //the row location of the 8x8 block we are reading

logic read_y;
logic read_u;
logic read_v;

logic [15:0] Sprime_row [2:0];

logic finish_reading;

logic [5:0] pixel_number_counter;
logic [4:0] pixel_num_counter_u_v;

logic [2:0] increase_Saddress;
logic signed [15:0] T_even;
logic signed [15:0] T_odd;

always @(posedge CLOCK_50_I or negedge Resetn) begin
	if (~Resetn) begin
		pixel_col <= 6'd0;
		pixel_row <= 9'd0;
		block_col <= 6'd0;
		block_row <= 5'd0;
		current_row_counter <= 3'd0;
		current_column_counter <= 3'd0;
		SRAM_address <= 18'd0;
		m2_finish <= 1'd0;
		m2_start <= 1'd0;
		finish_reading <= 1'd0;

		Sprime_row[0] <= 16'd0;
		Sprime_row[1] <= 16'd0;
		Sprime_row[2] <= 16'd0;
		Sprime_row[3] <= 16'd0;
		Sprime_row[4] <= 16'd0;
		Sprime_row[5] <= 16'd0;
		Sprime_row[6] <= 16'd0;
		Sprime_row[7] <= 16'd0;

		pixel_number_counter <= 6'd0;
		pixel_num_counter_u_v <= 5'd0;


		//at reset, we start reading pre-IDCT y values FIRST 
		read_y <= 1'd1;
		read_u <= 1'd0;
		read_v <= 1'd0;

		//initialize the rest of the signals as we add them to the program

	end else begin

		case(m2_state)
			
		idle: begin
			if (m2_start) begin
				m2_state <= fill_lead_in0;
			end
		end

		//multiplying block row and 
		fill_lead_in0: begin
			m1_op1 <= block_col;
			m1_op2 <= 32'd8;
			m2_op1 <= block_row;
			m2_op2 <= 32'd2560;

			m2_state <= fill_lead_in1;
		end

		//read S'0 and C
		fill_lead_in1: begin
			
			write_en_n <= 1'b1;

			//statements to move SRAM_address to the next 8x8 block if respective signals are high
			if (read_y) begin
				SRAM_address <= pre_IDCT_Y + m1_out + m2_out;
			end else if (read_u) begin
				SRAM_address <= pre_IDCT_U + m1_out + m2_out;
			end else if (read_v) begin
				SRAM_address <= pre_IDCT_V + m1_out + m2_out;
			end

			address0 <= 18'd0;
			pixel_number_counter <= 6'd0;
		
			m2_state <= fill_lead_in2;
		end

		//read S'1 and C
		fill_lead_in2: begin
			SRAM_address <= SRAM_address + 18'd1;
			pixel_number_counter <= pixel_number_counter + 6'd1;
			m2_state <= fill_lead_in3;
		end
		
		//read S'2 and C
		fill_lead_in3: begin
			SRAM_address <= SRAM_address + 18'd1;
			pixel_number_counter <= pixel_number_counter + 6'd1;
			m2_state <= fill_CC0;
		end

		//read S'3 and store S'0
		fill_CC0: begin
			SRAM_address <= SRAM_address + 18'd1;
			pixel_number_counter <= pixel_number_counter + 6'd1;
			write_en0 <= 1'b0;
			Sprime_row[0] <= SRAM_read_data;
			m2_state <= fill_CC1;
		end

		//read S'4 and store S'1
		fill_CC1: begin
			SRAM_address <= SRAM_address + 18'd1;
			pixel_number_counter <= pixel_number_counter + 6'd1;
			Sprime_row[1] <= SRAM_read_data;

			m2_state <= fill_CC2;
		end

		//read S'5 and store S'2
		fill_CC2: begin
			SRAM_address <= SRAM_address + 18'd1;
			pixel_number_counter <= pixel_number_counter + 6'd1;
			Sprime_row[2] <= SRAM_read_data;
			m2_state <= fill_CC3;
		end

		//read S'6 and store S'3
		fill_CC3: begin
			SRAM_address <= SRAM_address + 18'd1;
			pixel_number_counter <= pixel_number_counter + 6'd1;
			Sprime_row[3] <= SRAM_read_data;
			m2_state <= fill_CC4;
		end

		//read S'7 and store S'4
		fill_CC4: begin
			SRAM_address <= SRAM_address + 18'd1;
			pixel_number_counter <= pixel_number_counter + 6'd1;
			Sprime_row[4] <= SRAM_read_data;
			m2_state <= fill_CC5;
		end

		//store S'5 and write (S'0, S'1) to DP-RAM0
		fill_CC5: begin
			write_en0 <= 1'b1;
			data_in0 <= {Sprime_row[0], Sprime_row[1]};
			Sprime_row[5] <= SRAM_read_data;
			m2_state <= fill_CC6;
		end

		//store S'6, write (S'2, S'3) to DP-RAM0, and read S'320
		fill_CC6: begin
		
			if (read_y) begin
				SRAM_address <= SRAM_address + 18'd320;
				pixel_number_counter <= pixel_number_counter + 6'd1;
			end else begin
				SRAM_address <= SRAM_address + 18'd160;
				pixel_number_counter <= pixel_number_counter + 6'd1;
			end

			address0 <= address0 + 18'd1;
			
			data_in0 <= {Sprime_row[2], Sprime_row[3]};

			Sprime_row[6] <= SRAM_read_data;
			m2_state <= fill_CC7;

		end

		fill_CC7: begin
			SRAM_address <= SRAM_address + 18'd1;
			pixel_number_counter <= pixel_number_counter + 6'd1;

			address0 <= address0 + 18'd1;
			data_in0 <= {Sprime_row[4], Sprime_row[5]};
			Sprime_row[7] <= SRAM_read_data;
	
			m2_state <= fill_CC8;
		end

		fill_CC8: begin
			SRAM_address <= SRAM_address + 18'd1;
			pixel_number_counter <= pixel_number_counter + 6'd1;

			address0 <= address0 + 18'd1;
			data_in0 <= {Sprime_row[6], Sprime_row[7]};

			//if we hit the 64th pixel for a 8x8 y block, or the 32nd pixel for a 4x8 u/v block
			if (((pixel_number_counter == 6'd55) && (read_y)) || ((pixel_number_counter == 6'd31) && (read_u || read_v))) begin
				pixel_number_counter <= 6'd0;
				m2_state <= fill_lead_out0;
			end else begin
				m2_state <= fill_CC1;
			end
		end 


		//read S'3 and store S'0
		fill_lead_out0: begin
			SRAM_address <= SRAM_address + 18'd1;
			write_en0 <= 1'b0;
			Sprime_row[0] <= SRAM_read_data;
			m2_state <= fill_lead_out1;
		end

		//read S'4 and store S'1
		fill_lead_out1: begin
			SRAM_address <= SRAM_address + 18'd1;
			Sprime_row[1] <= SRAM_read_data;

			m2_state <= fill_lead_out2;
		end

		//read S'5 and store S'2
		fill_lead_out2: begin
			SRAM_address <= SRAM_address + 18'd1;
			Sprime_row[2] <= SRAM_read_data;
			m2_state <= fill_lead_out3;
		end

		//read S'6 and store S'3
		fill_lead_out3: begin
			SRAM_address <= SRAM_address + 18'd1;
			Sprime_row[3] <= SRAM_read_data;
			m2_state <= fill_lead_out4;
		end

		//read S'7 and store S'4
		fill_lead_out4: begin
			SRAM_address <= SRAM_address + 18'd1;
			Sprime_row[4] <= SRAM_read_data;
			m2_state <= fill_lead_out5; 
		end

		//store S'5 and write (S'0, S'1) to DP-RAM0
		fill_lead_out5: begin
			write_en0 <= 1'b1;
			data_in0 <= {Sprime_row[0], Sprime_row[1]};
			Sprime_row[5] <= SRAM_read_data;
			m2_state <= fill_lead_out6;
		end

		//store S'6, write (S'2, S'3) to DP-RAM0, and read S'320
		fill_lead_out6: begin

			address0 <= address0 + 18'd1;
			data_in0 <= {Sprime_row[2], Sprime_row[3]};

			Sprime_row[6] <= SRAM_read_data;
			m2_state <= fill_lead_out7;

		end

		fill_lead_out7: begin
			address0 <= address0 + 18'd1;
			data_in0 <= {Sprime_row[4], Sprime_row[5]};
			Sprime_row[7] <= SRAM_read_data;
	
			m2_state <= fill_lead_out8;
		end

		fill_lead_out8: begin
			address0 <= address0 + 18'd1;
			data_in0 <= {Sprime_row[6], Sprime_row[7]};

			m2_state <= tcalc_lead_in0;
			block_col <= block_col + 6'd1;

			/* moving this to end of Scalc
			//check which Y/U/V block we are reading, and either incriment to the next row/column or change to the next Y/U/V block
			if (read_y) begin
				if (block_col > 6'd39) begin
					block_col <= 6'd0;
					block_row <= block_row + 5'd1;
				end
				
				if (block_row > 5'29) begin
					block_row <= 5'd0;
					read_u <= 1'd1;
					read_y <= 1'd0;
					read_v <= 1'd0;
				end

			end else if (read_u) begin
				if (block_col > 6'd19) begin
					block_col <= 6'd0;
					block_row <= block_row + 5'd1;
				end
				
				if (block_row > 5'29) begin
					block_row <= 5'd0;
					read_u <= 1'd0;
					read_y <= 1'd0;
					read_v <= 1'd1;
				end

			end else begin
				if (block_col > 6'd19) begin
					block_col <= 6'd0;
					block_row <= block_row + 5'd1;
				end
				
				if (block_row > 5'29) begin
					finish_reading <= 1'b1;
				end
			end
			*/

			m2_state <= tcalc_lead_in0;
		end 

		//read first location
		t_calc_lead_in0: begin

			increase_Saddress <= 8'd0;

			//for DP-RAM0 
			address0 <= 18'd0;
			write_en0 <= 1'd0;

			address1 <= 18'd0;
			write_en1 <= 1'd0;

			m2_state <= t_calc_lead_in1;

		end
		
		//read second location
		t_calc_lead_in1: begin

			//for DP-RAM0 
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;
			
			m2_state <= t_calc_lead_in2;

		end

		//read (S'2,S'3) and calculate T(S'0,S'1)
		t_calc_lead_in2: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;
			
			//begin calculation for S0*C0
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S1*C8
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_lead_in3;

		end

		//read (S'4, S'5) and calculate T(S'2, S'3)
		t_calc_lead_in3: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;

			increase_Saddress <= increase_Saddress + 8'd1;
			
			T_even <= m1_out + m2_out;

			//begin calculation for S2*C16
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S3*C24
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_lead_in4;


		end
		
		//read (S'6, S'7) and calculate T(S'6, S'7)
		t_calc_lead_in4: begin
			
			//for DP-RAM0
			address0 <= address0 - 18'd3;
			address1 <= address1 + 18'd1;

			T_even <= T_even + m1_out + m2_out;
			
			//begin calculation for S4*C32
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S5*C40
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_lead_in5;

		end

		t_calc_lead_in5: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;

			T_even <= T_even + m1_out + m2_out;
			
			//begin calculation for S6*C48
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S7*C56
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_lead_in6;

		end

		t_calc_lead_in6: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;

			T_even <= T_even + m1_out + m2_out; //t even is done calculating

			//begin calculation for S0*C1
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S1*C9
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_lead_in7;

		end

		t_calc_lead_in7: begin
			
			//for DP-RAM0
			address0 <= address0 - 18'd3;
			address1 <= address1 + 18'd1;

			increase_Saddress <= increase_Saddress + 8'd1;

			T_odd <= m1_out + m2_out;

			//begin calculation for S4*C33
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S5*C41
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_lead_in8;

		end

		t_calc_lead_in8: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;

			T_odd <= m1_out + m2_out; 

			//begin calculation for S2*C17
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S3*C25
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];
			
			m2_state <= t_calc_lead_in9;

		end

		t_calc_lead_in9: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;

			T_odd <= T_odd + m1_out + m2_out;

			//begin calculation for S6*C49
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S7*C57
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_lead_in10;

		end

		t_calc_lead_in10: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;

			//for DP-RAM1
			address2 <= 18'd0;
			write_en2 <= 1'd1;
			data_in2 <= {(T_even >>> 8), (T_odd + m1_out + m2_out) >>> 8)}; //finish calculating T1 and write (T0,T1) to DP-RAM1

			//begin calculation for S0*C2
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S1*C10
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_CC_0;

		end
		
		//read (S'2, S'3) and calculate T(S'0, S'1)
		t_calc_CC_0: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;

			increase_Saddress <= increase_Saddress + 3'd1; //used to increase address by 4

			T_even <= m1_out + m2_out;

			//begin calculation for S2*C18
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S3*C36
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_CC_1;

		end

		//read (S'4, S'5) and calculate T(S'2, S'3)
		t_calc_CC_1: begin
			
			address0 <= address0 - 18'd3;
			address1 <= address1 + 18'd1;

			T_even <= T_even + m1_out + m2_out;

			//begin calculation for S4*C34
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S5*C42
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_CC_2;

		end
		
		t_calc_CC_2: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;


			T_even <= T_even + m1_out + m2_out;

			//begin calculation for S6*C50
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S7*C58
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_CC_3;

		end
		
		t_calc_CC_3: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;

			T_even <= T_even + m1_out + m2_out; //T_even has been fully calculated

			//begin calculation for S0*C3
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S1*C11
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_CC_4;

		end

		t_calc_CC_4: begin

			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;
			
			increase_Saddress <= increase_Saddress + 3'd1;

			T_odd <= m1_out + m2_out; //begin calculating T_odd

			//begin calculation for S2*C19
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S3*C27
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_CC_5;

		end

		t_calc_CC_5: begin
			
			if (increase_Saddress == 3'd7) begin
				//for DP-RAM0
				address0 <= address0 + 18'd1;
				address1 <= address1 + 18'd1;
				
			end else begin
				//for DP-RAM0
				address0 <= address0 - 18'd3;
				address1 <= address1 + 18'd1;

			end
			

			T_odd <= T_odd + m1_out + m2_out;

			//begin calculation for S4*C35
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S5*C43
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_CC_6;
			
		end

		t_calc_CC_6: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;

			T_odd <= T_odd + m1_out + m2_out;

			//begin calculation for S6*C51
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S7*C59
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			m2_state <= t_calc_CC_7;

		end
		
		
		t_calc_CC_7: begin
			
			//for DP-RAM0
			address0 <= address0 + 18'd1;
			address1 <= address1 + 18'd1;

			//for DP-RAM1
			address2 <= address2 + 18'd1;
			write_en2 <= 1'd1;

			data_in2 <= {(T_even >>> 8), ((T_odd + m1_out + m2_out) >>> 8)}; //finish calculating T_odd and write (T_even,T_odd) to DP-RAM1

			//begin calculation for S0*C4
			m1_op1 <= data_out0[31:16];
			m1_op2 <= data_out1[31:16];

			//begin calculation for S1*C12
			m2_op1 <= data_out0[15:0];
			m2_op2 <= data_out1[15:0];

			if ((read_y && (address0 > 18'd31)) || ((read_u || read_v) && (address0 > 18'd15))) begin
				m2_state <= S_calc_lead_in0;
			end else begin
				m2_state <= t_calc_CC_0;
			end

		end
		


	end

end


endmodule