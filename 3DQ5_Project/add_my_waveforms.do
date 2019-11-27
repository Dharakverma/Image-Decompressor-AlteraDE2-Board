

# add waves to waveform
add wave Clock_50
add wave -divider {Top level signals}
add wave uut/SRAM_we_n
add wave -hex uut/SRAM_write_data
add wave -hex uut/SRAM_read_data
add wave -unsigned uut/SRAM_address
add wave uut/top_state

add wave -divider {M1 signals}
add wave uut/m1_unit/milestone1
add wave -unsigned uut/m1_unit/reg_y
add wave -unsigned uut/m1_unit/reg_u
add wave -unsigned uut/m1_unit/reg_v
add wave -dec uut/m1_unit/mult1_op1
add wave -dec uut/m1_unit/mult1_op2
add wave -dec uut/m1_unit/mult2_op1
add wave -dec uut/m1_unit/mult2_op2
add wave -dec uut/m1_unit/mult3_op1
add wave -dec uut/m1_unit/mult3_op2
add wave -dec uut/m1_unit/mult1_out
add wave -dec uut/m1_unit/mult2_out
add wave -dec uut/m1_unit/mult3_out
add wave -unsigned uut/m1_unit/value_v_prime
add wave -unsigned uut/m1_unit/value_u_prime
add wave -dec uut/m1_unit/matrix_value_y
add wave -dec uut/m1_unit/matrix_value_u
add wave -dec uut/m1_unit/matrix_value_v
add wave -unsigned uut/m1_unit/value_R
add wave -unsigned uut/m1_unit/value_G
add wave -unsigned uut/m1_unit/value_B
add wave -unsigned uut/m1_unit/read_cycle_en
add wave -dec uut/m1_unit/address_y
add wave -dec uut/m1_unit/address_u
add wave -dec uut/m1_unit/address_v
add wave -unsigned uut/m1_unit/counter
add wave -unsigned uut/m1_unit/counter_vert
add wave -divider {Clipped Signals}
add wave -unsigned uut/m1_unit/clip_R
add wave -unsigned uut/m1_unit/clip_G
add wave -unsigned uut/m1_unit/clip_B
add wave -unsigned uut/m1_unit/clip_R_p
add wave -unsigned uut/m1_unit/clip_G_p
add wave -unsigned uut/m1_unit/clip_B_p
add wave -unsigned uut/m1_unit/temp_R
add wave -unsigned uut/m1_unit/temp_G
add wave -unsigned uut/m1_unit/temp_B


















