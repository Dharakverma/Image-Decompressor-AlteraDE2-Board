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

parameter pre_IDCT_offset = 18'd76800,
		  u_offset = 18'd38400,
		  v_offset = 18'd57600,
		  
;

//for dp rams, gotta check previous lab to set these up!!!! i will do it
logic [17:0] address0;
logic [31:0] data_in0;
logic write_en0;
logic [31:0] data_out0;

logic [17:0] address1;
logic [31:0] data_in1;
logic write_en1;
logic [31:0] data_out1;

logic [7:0] S; // output is 8 bit unsigned
logic [5:0] block_col; //to 39
logic [4:0] block_row; //to 29
logic [8:0] pixel_col;
logic [7:0] pixel_row;
logic [15:0] Sprime_row [2:0];

always @(posedge CLOCK_50_I or negedge Resetn) begin
	if (~Resetn) begin
		pixel_col <= 6'b0;
		//add the rest

	end else begin

		case(m2_state)
			
		idle: begin
			if (m2_start) begin
				m2_state <= fill_lead_in0;

			end

		end

		fill_lead_in0: begin
		
			write_en_n <= 1'b1;
			SRAM_address <= ;		

			m2_state <= fill_lead_in1;
		end

		fill_lead_in1: begin
			SRAM_address <= SRAM_address + 18'd1;

			m2_state <= fill_lead_in2;
		end
		
		fill_lead_in2: begin
			SRAM_address <= SRAM_address + 18'd1;
	
			m2_state <= fill_CC0;
		end

		fill_CC0: begin
			SRAM_address <= SRAM_address + 18'd1;

			Sprime_row[0] <= SRAM_read_data;
	
			m2_state <= fill_CC1;
		end

		fill_CC1: begin
			SRAM_address <= SRAM_address + 18'd1;

			Sprime_row[1] <= SRAM_read_data;
	
			m2_state <= fill_CC2;
		end

		fill_CC2: begin
			SRAM_address <= SRAM_address + 18'd1;

			Sprime_row[2] <= SRAM_read_data;
	
			m2_state <= fill_CC3;
		end

		fill_CC3: begin
			SRAM_address <= SRAM_address + 18'd1;

			Sprime_row[3] <= SRAM_read_data;
	
			m2_state <= fill_CC3;
		end

		fill_CC4: begin
			SRAM_address <= SRAM_address + 18'd1;

			Sprime_row[4] <= SRAM_read_data;
	
			m2_state <= fill_CC3;
		end

		fill_CC5: begin
			pixel_row <= pixel_row + 8'd1;

			Sprime_row[5] <= SRAM_read_data;

			address0 <= pixel_row 
	
			m2_state <= fill_CC3;
		end

		fill_CC6: begin
			SRAM_address <= pre_IDCT_offset + pixel_col + pixel_row;

			Sprime_row[6] <= SRAM_read_data;
	
			m2_state <= fill_CC3;
		end

		fill_CC7: begin
			SRAM_address <= SRAM_address + 18'd1;

			Sprime_row[7] <= SRAM_read_data;
	
			m2_state <= fill_CC3;
		end

		fill_CC8: begin
			SRAM_address <= SRAM_address + 18'd1;

			Sprime_row[2] <= SRAM_read_data;
	
			m2_state <= fill_CC3;
		end 


	end

end


endmodule