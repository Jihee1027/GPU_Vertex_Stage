configure wave -signalnamewidth 1

add wave -divider "Clock and Reset"
add wave sim:/reciprocal_nr_tb/clk
add wave sim:/reciprocal_nr_tb/n_rst

add wave -divider "Current Input"
add wave sim:/reciprocal_nr_tb/stage
add wave sim:/reciprocal_nr_tb/in_valid
add wave -radix decimal sim:/reciprocal_nr_tb/denominator

add wave -divider "Pipeline Valid"
add wave -radix binary sim:/reciprocal_nr_tb/DUT/valid_pipe

add wave -divider "Input Normalize"
add wave -radix unsigned sim:/reciprocal_nr_tb/DUT/denominator_mag
add wave -radix unsigned sim:/reciprocal_nr_tb/DUT/msb_index
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/normalized_input
add wave -radix decimal sim:/reciprocal_nr_tb/DUT/scale_shift_input

add wave -divider "Stage 0 - Normalize Register"
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/normalized_s0
add wave -radix decimal sim:/reciprocal_nr_tb/DUT/scale_shift_s0
add wave sim:/reciprocal_nr_tb/DUT/sign_s0
add wave sim:/reciprocal_nr_tb/DUT/zero_s0

add wave -divider "Stage 1 - Initial Reciprocal"
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/normalized_s1
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/r0_s1
add wave -radix decimal sim:/reciprocal_nr_tb/DUT/scale_shift_s1

add wave -divider "Stage 2 - m x r0"
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/mr0_prod_s2
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/r0_s2

add wave -divider "Stage 3 - 2 - m x r0"
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/mr0_scaled
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/error0_s3
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/r0_s3

add wave -divider "Stage 4 - r1"
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/r1_s4
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/normalized_s4

add wave -divider "Stage 5 - m x r1"
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/mr1_prod_s5
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/r1_s5

add wave -divider "Stage 6 - 2 - m x r1"
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/mr1_scaled
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/error1_s6
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/r1_s6

add wave -divider "Stage 7 - r2"
add wave -radix hexadecimal sim:/reciprocal_nr_tb/DUT/r2_s7
add wave -radix decimal sim:/reciprocal_nr_tb/DUT/scale_shift_s7
add wave sim:/reciprocal_nr_tb/DUT/sign_s7
add wave sim:/reciprocal_nr_tb/DUT/zero_s7

add wave -divider "Stage 8 - Output"
add wave sim:/reciprocal_nr_tb/out_valid
add wave -radix decimal sim:/reciprocal_nr_tb/reciprocal
add wave sim:/reciprocal_nr_tb/div_zero

add wave -divider "Testbench Tracking"
add wave -radix decimal sim:/reciprocal_nr_tb/input_count
add wave -radix decimal sim:/reciprocal_nr_tb/output_count
add wave -radix decimal sim:/reciprocal_nr_tb/cycle_count
