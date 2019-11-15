

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
add wave -hex uut/m1_unit/reg_y


