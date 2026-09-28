configure wave -signalnamewidth 1
add wave -divider "Clock and Reset"
add wave sim:/perspective_divide_tb/clk
add wave sim:/perspective_divide_tb/n_rst
add wave -divider "Test"
add wave sim:/perspective_divide_tb/stage
add wave -radix decimal sim:/perspective_divide_tb/test_num
add wave -radix decimal sim:/perspective_divide_tb/pass_count
add wave -radix decimal sim:/perspective_divide_tb/fail_count
add wave -divider "Clip Space Input"
add wave sim:/perspective_divide_tb/in_valid
add wave -radix decimal sim:/perspective_divide_tb/x_clip
add wave -radix decimal sim:/perspective_divide_tb/y_clip
add wave -radix decimal sim:/perspective_divide_tb/z_clip
add wave -radix decimal sim:/perspective_divide_tb/w_clip
add wave -divider "Normalize"
add wave -radix decimal sim:/perspective_divide_tb/DUT/RECIPROCAL/abs_value
add wave -radix unsigned sim:/perspective_divide_tb/DUT/RECIPROCAL/highest_bit
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/normalized
add wave -radix decimal sim:/perspective_divide_tb/DUT/RECIPROCAL/shift_amount
add wave sim:/perspective_divide_tb/DUT/RECIPROCAL/input_valid
add wave sim:/perspective_divide_tb/DUT/RECIPROCAL/input_sign
add wave sim:/perspective_divide_tb/DUT/RECIPROCAL/input_zero
add wave -divider "Start Value"
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/start_value
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/nr_value
add wave sim:/perspective_divide_tb/DUT/RECIPROCAL/nr_valid
add wave -divider "First NR Iteration"
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/FIRST_ITERATION/value_in
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/FIRST_ITERATION/guess_in
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/FIRST_ITERATION/first_product
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/FIRST_ITERATION/adjust_value
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/FIRST_ITERATION/second_product
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/first_result
add wave sim:/perspective_divide_tb/DUT/RECIPROCAL/first_valid
add wave -divider "Second NR Iteration"
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/SECOND_ITERATION/value_in
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/SECOND_ITERATION/guess_in
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/SECOND_ITERATION/first_product
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/SECOND_ITERATION/adjust_value
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/SECOND_ITERATION/second_product
add wave -radix hexadecimal sim:/perspective_divide_tb/DUT/RECIPROCAL/final_result
add wave sim:/perspective_divide_tb/DUT/RECIPROCAL/final_valid
add wave -divider "Reciprocal Output"
add wave sim:/perspective_divide_tb/DUT/recip_valid
add wave sim:/perspective_divide_tb/DUT/recip_zero
add wave -radix decimal sim:/perspective_divide_tb/DUT/reciprocal
add wave -divider "Delayed Vector"
add wave -radix decimal sim:/perspective_divide_tb/DUT/x_delayed
add wave -radix decimal sim:/perspective_divide_tb/DUT/y_delayed
add wave -radix decimal sim:/perspective_divide_tb/DUT/z_delayed
add wave -divider "Perspective Multiply"
add wave sim:/perspective_divide_tb/DUT/mult_valid
add wave sim:/perspective_divide_tb/DUT/mult_zero
add wave -radix decimal sim:/perspective_divide_tb/DUT/x_product
add wave -radix decimal sim:/perspective_divide_tb/DUT/y_product
add wave -radix decimal sim:/perspective_divide_tb/DUT/z_product
add wave -divider "Scaled Output"
add wave -radix decimal sim:/perspective_divide_tb/DUT/x_scaled
add wave -radix decimal sim:/perspective_divide_tb/DUT/y_scaled
add wave -radix decimal sim:/perspective_divide_tb/DUT/z_scaled
add wave -divider "NDC Output"
add wave sim:/perspective_divide_tb/out_valid
add wave sim:/perspective_divide_tb/div_zero
add wave -radix decimal sim:/perspective_divide_tb/x_ndc
add wave -radix decimal sim:/perspective_divide_tb/y_ndc
add wave -radix decimal sim:/perspective_divide_tb/z_ndc