`timescale 1ns/100ps
`default_nettype none
 
`include "define_state.h"

//mulitplier module which we will instentiate 3 times 
module Multiplier (
	input int Mult_op_1, Mult_op_2,
	output int Mult_result
);

	logic [63:0] Mult_result_long;
	assign Mult_result_long = Mult_op_1 * Mult_op_2;
	assign Mult_result = Mult_result_long[31:0];

end module

//these mulitpliers are always running
//do not assign these values in your always ff
//**** need to add select statements in these multipliers to avoid errors in future, reference documentation ****
Multiplier mult1(
	.Mult_op_1(mult1_op1),
	.Mult_op_1(mult1_op2),
	.Mult_result(mult1_out),
);

Multiplier mult2(
	.Mult_op_1(mult2_op1),
	.Mult_op_1(mult2_op2),
	.Mult_result(mult2_out),
);

Multiplier mult3(
	.Mult_op_3(mult3_op1),
	.Mult_op_3(mult3_op2),
	.Mult_result(mult3_out),
);

module milestone1(
	input logic Clock,
	input logic Resetn,
	input logic start_bit, //for leaving idle state
	input logic [15:0] SRAM_read_data,
	output logic [15:0] write_data,
	//address is incrimented by 1 per cycle for Y values, but by 1 EVERY OTHER cycle for U and V values 
	output logic [17:0] address,
	output logic write_en_n,
	output logic milestone1_finish
);

milestone_state_type milestone1; //initailize from header file

//initalize registers for U,V,Y and RGB 
logic [7:0] reg_u [5:0]; //shift register for u values
logic [7:0] reg_v [5:0]; //shift register for v values 
logic [7:0] reg_y [5:0]; //shift register for y values 
logic [7:0] buff_reg_u [5:0]; //buffer for u values
logic [7:0] buff_reg_v [5:0]; //buffer for v values
logic [7:0] buff_reg_y [5:0]; //buffer for y values

logic even_or_odd; //to keep track of whether we need to incriment address for Y/U/V or not
logic [7:0] value_R;
logic [7:0] value_G;
logic [7:0] value_B;
logic [7:0] value_y;
logic [7:0] value_u;
logic [7:0] value_v;

//address counters for Y, U, and V
logic [17:0] address_y;
logic [17:0] address_u;
logic [17:0] address_v;

logic [31:0] value_U_prime;
logic [31:0] value_V_prime;

//intialize input and output (we use them as outputs, theyre not actually "outputs") logic for multipliers 
logic [31:0] Mult_op_1, Mult_op_2, Mult_result;
logic [63:0] Mult_result_long;

logic [7:0] mult1_op1;
logic [7:0] mult1_op2;
logic [7:0] mult2_op1;
logic [7:0] mult2_op2;
logic [7:0] mult3_op1;
logic [7:0] mult3_op2;

logic [7:0] mult1_out;
logic [7:0] mult2_out;
logic [7:0] mult3_out;

//constant ints for 32 bit signed arithmetic
int signed_21;
int signed_52;
int signed_159;
int signed_128;
int signed_76284;
int signed_16;


always //make ff begin
	if (~resetn) begin
	//initailize all variables and registers as base values
		value_R <= 8'd0;
		value_G <= 8'd0;
		value_B <= 8'd0;
		value_y <= 8'd0;
		value_u <= 8'd0;
		value_v <= 8'd0;
		value_U_prime <= 8'd0;
		value_V_prime <= 8'd0;
		even_or_odd <= 16'd0;

		address_y <= 18'd0;
		address_u <= 18'd38400;
		address_v <= 18'd57600;

		reg_y[0] <= 8'd0;
		reg_y[1] <= 8'd0;
		reg_y[2] <= 8'd0;
		reg_y[3] <= 8'd0;
		reg_y[4] <= 8'd0;
		reg_y[5] <= 8'd0;

		reg_u[0] <= 8'd0;
		reg_u[1] <= 8'd0;
		reg_u[2] <= 8'd0;
		reg_u[3] <= 8'd0;
		reg_u[4] <= 8'd0;
		reg_u[5] <= 8'd0;

		reg_v[0] <= 8'd0;
		reg_v[1] <= 8'd0;
		reg_v[2] <= 8'd0;
		reg_v[3] <= 8'd0;
		reg_v[4] <= 8'd0;
		reg_v[5] <= 8'd0;
		
		//assign the constants for multiplying 
		signed_21 <= 32'd21;
		signed_52 <= 32'd52;
		signed_159 <= 32'd159;
		signed_128 <= 32'd128;
		signed_76284 <= 32'd76284;
		signed_16 <= 32'd16;
		
	end else begin
		
		case(milestone1)
			
			common_case_0: begin

				//enable reading -> read (Veven, Vodd) values -> stores values in reg_v register
				write_en_n <= 1'b1; 

				if (write_en_n == 1'b1 && even_or_odd == 1'b1) begin
					
					address <= address_v;
					address_v <= address_v + 18'd1; 
					
				end else begin

				 //this means we need to read V and U values this cycle

				//Y matrix calculation for R value
				//the output of this multiplication will be available in the next cycle
				mutl1_op1 <= signed_76284;
				mult1_op2 <= (reg_y[5] - signed_16);
			
				//V matrix calculation for R value
				//the output of this multiplication will be available in the next cycle
				mult2_op1 <= signed_76284;
				mult2_op2 <= (reg_v[5] - signed_128);

				milestone1 <= common_case_1;
				
			end

			common_case_1: begin

				value_y <= $signed(mult1_out);
				value_v <= $signed(mult2_out);
				value_R <= $signed((value_y + value_v)) >>> 16;	

				even_or_odd <= even_or_odd ~& 1'b1;

			end

			common_case_2: begin
				
				mult1_op1 <= signed_21;
				mutl1_op2 <=(reg_u[0] + reg_u[5]); //the u values we require will always be at the start and end of our register
				
				mult2_op1 <= signed_52; //how do i make this negative
				mult2_op2 <= (reg_u[1] + reg_u[4]);
				
				mult3_op1 <= signed_159;
				mult3_op2 <= (reg_u[2] + reg_u[3]);
			
				value_U_prime <= mult1_out + mult2_out + mult3_out + signed_128; 
				value_U_prime <= $signed(value_U_prime) >>> 8; // this is equivalent to dividing by 256 (2^8)
				
				milestone1 <= common_case_2:
				
			end
			
			common_case_3: begin

				reg_v[5] <= SRAM_read_data[7:0]; //new even value from read we initiated 3 cycles ago
				reg_v[4] <= SRAM_read_data[15:8]; //new odd value from read we initiated 3 cycles ago


				//we need to ensure we shift these values to the correct index for our V' calculation
				//index 0 == V(j-5/2) required data
				//index 1 == V(j-3/2)
				//index 2 == V(j-1/2)
				//index 3 == V(j+1/2)
				//index 4 == V(j+3/2)
				//index 5 == V(j+5/2)
				//need to create a buffer register and shift only 1 out of 2 of the SRAM values into this register per cycle
				reg_v[4] <= reg_v[5];
				reg_v[3] <= reg_v[4];
				reg_v[2] <= reg_v[3];
				reg_v[1] <= reg_v[2];
				reg_v[0] <= reg_v[1];

		
end




//add module from document for "mulipliers" 

//add states for common case

//create always ff for checking resetn and shifting registers for U, V to 0 

//use finish state and send to top FSM

//need to create a 16 bit buffer register to store future V and U values

end module