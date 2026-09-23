add wave -divider "Test Stage"
add wave -radix decimal sim:/row_mac_tb/stage

add wave -divider "Vertex Inputs"
add wave -radix decimal sim:/row_mac_tb/x
add wave -radix decimal sim:/row_mac_tb/y
add wave -radix decimal sim:/row_mac_tb/z
add wave -radix decimal sim:/row_mac_tb/w

add wave -divider "Matrix Row"
add wave -radix decimal sim:/row_mac_tb/m0
add wave -radix decimal sim:/row_mac_tb/m1
add wave -radix decimal sim:/row_mac_tb/m2
add wave -radix decimal sim:/row_mac_tb/m3

add wave -divider "Products"
add wave -radix decimal sim:/row_mac_tb/DUT/p0
add wave -radix decimal sim:/row_mac_tb/DUT/p1
add wave -radix decimal sim:/row_mac_tb/DUT/p2
add wave -radix decimal sim:/row_mac_tb/DUT/p3

add wave -divider "Extended Products"
add wave -radix decimal sim:/row_mac_tb/DUT/p0_ext
add wave -radix decimal sim:/row_mac_tb/DUT/p1_ext
add wave -radix decimal sim:/row_mac_tb/DUT/p2_ext
add wave -radix decimal sim:/row_mac_tb/DUT/p3_ext

add wave -divider "MAC Result"
add wave -radix decimal sim:/row_mac_tb/DUT/sum
add wave -radix decimal sim:/row_mac_tb/DUT/scaled

add wave -divider "Output"
add wave -radix decimal sim:/row_mac_tb/result