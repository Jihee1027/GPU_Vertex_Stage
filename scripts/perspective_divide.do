configure wave -signalnamewidth 1

add wave -divider "Clock and Reset"
add wave sim:/perspective_divide_tb/clk
add wave sim:/perspective_divide_tb/n_rst

add wave -divider "Test"
add wave sim:/perspective_divide_tb/stage
add wave -radix decimal sim:/perspective_divide_tb/test_num

add wave -divider "Clip Space Input"
add wave sim:/perspective_divide_tb/in_valid
add wave -radix decimal sim:/perspective_divide_tb/x_clip
add wave -radix decimal sim:/perspective_divide_tb/y_clip
add wave -radix decimal sim:/perspective_divide_tb/z_clip
add wave -radix decimal sim:/perspective_divide_tb/w_clip


add wave -divider "Reciprocal Pipeline"
add wave -radix binary sim:/perspective_divide_tb/DUT/recip/valid_pipe

add wave -divider "Stage 0 - Normalize"
add wave -radix unsigned sim:/perspective_divide_tb/DUT/recip/denominator_mag
add wave -radix unsigned sim:/perspective_divide_tb/DUT/recip/msb_index
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/recip/normalized_s0
add wave -radix decimal sim:/perspective_divide_tb/DUT/recip/scale_shift_s0

add wave -divider "Stage 1 - Initial Reciprocal"
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/recip/r0_s1

add wave -divider "Stage 2 - m x r0"
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/recip/mr0_prod_s2

add wave -divider "Stage 3 - Error 0"
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/recip/error0_s3

add wave -divider "Stage 4 - r1"
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/recip/r1_s4

add wave -divider "Stage 5 - m x r1"
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/recip/mr1_prod_s5

add wave -divider "Stage 6 - Error 1"
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/recip/error1_s6

add wave -divider "Stage 7 - r2"
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/recip/r2_s7

add wave -divider "Reciprocal Output"
add wave sim:/perspective_divide_tb/DUT/recip_valid
add wave -radix decimal sim:/perspective_divide_tb/DUT/reciprocal
add wave sim:/perspective_divide_tb/DUT/recip_div_zero


add wave -divider "Delayed Vector"
add wave -radix decimal sim:/perspective_divide_tb/DUT/x_delayed
add wave -radix decimal sim:/perspective_divide_tb/DUT/y_delayed
add wave -radix decimal sim:/perspective_divide_tb/DUT/z_delayed


add wave -divider "Perspective Multiply"
add wave sim:/perspective_divide_tb/DUT/mult_valid
add wave sim:/perspective_divide_tb/DUT/mult_div_zero
add wave -radix decimal sim:/perspective_divide_tb/DUT/x_product
add wave -radix decimal sim:/perspective_divide_tb/DUT/y_product
add wave -radix decimal sim:/perspective_divide_tb/DUT/z_product


add wave -divider "NDC Output"
add wave sim:/perspective_divide_tb/out_valid
add wave sim:/perspective_divide_tb/div_zero
add wave -radix decimal sim:/perspective_divide_tb/x_ndc
add wave -radix decimal sim:/perspective_divide_tb/y_ndc
add wave -radix decimal sim:/perspective_divide_tb/z_ndc