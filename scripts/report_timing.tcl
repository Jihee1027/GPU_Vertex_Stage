set top [lindex $argv 0]
set freq [lindex $argv 1]

set period [expr {1000.0 / $freq}]

set checkpoints [glob -nocomplain ./build/${top}.runs/impl_1/*_routed.dcp]

if {[llength $checkpoints] == 0} {
	puts "ERROR: Routed checkpoint not found for $top"
	exit 1
}

set checkpoint [lindex $checkpoints 0]

puts "Opening $checkpoint"
open_checkpoint $checkpoint

if {[llength [get_clocks -quiet clk]] == 0} {
	create_clock -name clk -period $period [get_ports clk]
}

puts "Clock period = $period ns"
puts "Target frequency = $freq MHz"

report_clocks

report_timing_summary \
	-file ./build/timing.rpt

report_timing \
	-delay_type max \
	-max_paths 10 \
	-append \
	-file ./build/timing.rpt

exit