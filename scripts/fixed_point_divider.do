configure wave -signalnamewidth 1

add wave -divider "Clock and Reset"
add wave sim:/fixed_point_divider_tb/clk
add wave sim:/fixed_point_divider_tb/n_rst
add wave sim:/fixed_point_divider_tb/start

add wave -divider "Test"
add wave sim:/fixed_point_divider_tb/stage

add wave -divider "Inputs"
add wave -radix decimal sim:/fixed_point_divider_tb/numerator
add wave -radix decimal sim:/fixed_point_divider_tb/denominator

add wave -divider "Input Magnitudes"
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/numerator_mag
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/denominator_mag
add wave sim:/fixed_point_divider_tb/DUT/result_sign

add wave -divider "Control"
add wave sim:/fixed_point_divider_tb/DUT/state
add wave sim:/fixed_point_divider_tb/busy
add wave sim:/fixed_point_divider_tb/done
add wave sim:/fixed_point_divider_tb/div_zero
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/count

add wave -divider "Division Datapath"
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/dividend
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/divisor
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/remainder
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/shifted_remainder
add wave sim:/fixed_point_divider_tb/DUT/quotient_bit
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/quotient_work

add wave -divider "Division Step"
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/step_remainder
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/step_quotient
add wave -radix decimal sim:/fixed_point_divider_tb/DUT/final_quotient

add wave -divider "Next Values"
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/n_dividend
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/n_remainder
add wave -radix unsigned sim:/fixed_point_divider_tb/DUT/n_quotient_work

add wave -divider "Output"
add wave -radix decimal sim:/fixed_point_divider_tb/quotient
