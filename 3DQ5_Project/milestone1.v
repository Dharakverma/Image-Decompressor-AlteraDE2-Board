`timescale 1ns/100ps
`default_nettype none
 
`include "define_state.h"

module milestone1(
	input logic Clock,
	input logic Resetn,
	input logic start_bit, //for leaving idle state
	input logic [15:0] SRAM_read_data,
	output logic [15:0] write_data,
	output logic [17:0] address,
	output logic write_en_n,
	output logic milestone1_finish
);

milestone_state_type milestone1; //initailize from header file

//initalize registers for U,V,Y and RGB 
logic [7:0] reg_u [5:0]; //shift register for u values
logic [7:0] reg_v [5:0]; //shift register for v values 
logic [15:0] counter; //counter to keep track of where we are in memory
logic [7:0] value_R;
logic [7:0] value_G;
logic [7:0] value_B;
logic [7:0] value_U_prime;
logic [7:0] value_V_prime;
logic select_1; //used to enable specific multiplier
logic select_2;
logic select_3;

logic [31:0] Mult_op_1, Mult_op_2, Mult_result;
logic [63:0] Mult_result_long;

//constant ints for 32 bit signed arithmetic
int signed_21;
int signed_52;
int signed_159;
int signed_128;

assign Mult_result_long = Mult_op_1 * Mult_op_2;
assign Mult_result = Mult_result_long[31:0];

//three multipliers defined below
always_comb begin
	if (select_1 == 1'b0) begin
		op1 = b;
		op2 = c;
	end else begin
		op1 = d;
		op2 = e;
	end
end
assign a = op1*op2;

always_comb begin
	if (select_2 == 1'b0) begin
		op3 = f;
		op4 = g;
	end else begin
		op3 = h;
		op4 = i;
	end
end
assign b = op1*op2;

always_comb begin
	if (select_3 == 1'b0) begin
		op5 = j;
		op6 = k;
	end else begin
		op5 = l;
		op6 = m;
	end
end
assign c = op1*op2;

always @(posedge CLOCK_50_I or negedge resetn) begin
	if (~resetn) begin
	//initailize all variables and registers as 0 
		value_R = 8'd0;
		value_G = 8'd0;
		value_B = 8'd0;
		value_U_prime = 8'd0;
		value_V_prime = 8'd0;
		counter = 16'd0;
		select_1 = 1'b0;
		select_2 = 1'b0;
		select_3 = 1'b0;

		reg_u[0] = 8'd0;
		reg_u[1] = 8'd0;
		reg_u[2] = 8'd0;
		reg_u[3] = 8'd0;
		reg_u[4] = 8'd0;
		reg_u[5] = 8'd0;

		reg_v[0] = 8'd0;
		reg_v[1] = 8'd0;
		reg_v[2] = 8'd0;
		reg_v[3] = 8'd0;
		reg_v[4] = 8'd0;
		reg_v[5] = 8'd0;
		
		//assign the constants for multiplying 
		signed_21 = 32'd21;
		signed_52 = 32'd52;
		signed_159 = 32'd159;
		signed_128 = 32'd128;
		
	end else begin
		
		case(milestone1)
			common_case_1: begin
				
				select_1 = 1'b0;
				op1 = signed_21;
				op2 =(reg_u[0] + reg_u[5]); //the u values we require will always be at the start and end of our register
				
				select_2 = 1'b0;
				op3 = signed_52; //how do i make this negative
				op4 = (reg_u[1] + reg_u[4]);
				
				select_3 = 1'b0;
				op5 = signed_159;
				op6 = (reg_u[2] + reg_u[3]);
			
				value_U_prime = op1 + op2 + op3 + op4 + signed_128; 
				value_U_prime = 8 >> value_U_prime; // this is equivalent to dividing by 128 (2^8)
				milestone1 <= common_case_2:
				
			end
			
			common_case_2: begin
			
				select_1 = 1'b0;
				op1 = signed_21;
				op2 =(reg_v[0] + reg_v[5]); //the u values we require will always be at the start and end of our register
				
				select_2 = 1'b0;
				op3 = signed_52; //how do i make this negative
				op4 = (reg_v[1] + reg_v[4]);
				
				select_3 = 1'b0;
				op5 = signed_159;
				op6 = (reg_v[2] + reg_v[3]);
				
				
			
			end
		
end




//add module from document for "mulipliers" 

//add states for common case

//create always ff for checking resetn and shifting registers for U, V to 0 

//use finish state and send to top FSM