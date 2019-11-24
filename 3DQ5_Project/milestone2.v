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
logic [5:0] block_col; //to 40
logic [4:0] block_row; //to 30
logic [8:0] pixel_col;
logic [7:0] pixel_row;

always @(posedge CLOCK_50_I or negedge Resetn) begin
	if (~Resetn) begin

	end else begin

		case(m2_state)
			
		idle: begin
			
		end

		fill_lead_in0: begin
			pixel_col <= block_col * 5'd8;
			pixel_row <= block_row * 4'd8;

			SRAM_address <= pre_IDCT_offset + 


		end
		


	end

end


endmodule