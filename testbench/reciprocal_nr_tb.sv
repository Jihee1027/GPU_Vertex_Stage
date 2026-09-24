`timescale 1ns/1ns

module reciprocal_nr_tb;

	parameter DATA_W = 24;
	parameter FRAC_W = 8;
	parameter RECIP_W = 32;
	parameter RECIP_FRAC = 20;

	localparam NUM_TESTS = 9;
	localparam TOLERANCE = 4;

	logic clk, n_rst;
	logic in_valid;
	logic signed [DATA_W-1:0] denominator;

	logic out_valid;
	logic signed [RECIP_W-1:0] reciprocal;
	logic div_zero;

	logic signed [RECIP_W-1:0] expected_values [0:NUM_TESTS-1];
	logic expected_zero [0:NUM_TESTS-1];
	string test_names [0:NUM_TESTS-1];

	string stage;

	integer input_count;
	integer output_count;
	integer cycle_count;
	integer last_output_cycle;
	integer diff;


	reciprocal_nr #(
		.DATA_W(DATA_W),
		.FRAC_W(FRAC_W),
		.RECIP_W(RECIP_W),
		.RECIP_FRAC(RECIP_FRAC)
	) DUT (
		.clk(clk),
		.n_rst(n_rst),
		.in_valid(in_valid),
		.denominator(denominator),
		.out_valid(out_valid),
		.reciprocal(reciprocal),
		.div_zero(div_zero)
	);


	// 125 MHz clock
	always #4 clk = ~clk;


	// Count clock cycles
	always @(posedge clk) begin
		if (!n_rst) begin
			cycle_count = 0;
		end
		else begin
			cycle_count = cycle_count + 1;
		end
	end


	task send_test(
		input logic signed [DATA_W-1:0] test_denominator,
		input logic signed [RECIP_W-1:0] expected,
		input logic expected_div_zero,
		input string test_name
	);

		begin
			@(negedge clk);

			stage = test_name;
			denominator = test_denominator;
			in_valid = 1'b1;

			expected_values[input_count] = expected;
			expected_zero[input_count] = expected_div_zero;
			test_names[input_count] = test_name;

			input_count = input_count + 1;
		end
	endtask


	// Check pipeline outputs
	always @(negedge clk) begin
		if (n_rst && out_valid && output_count < NUM_TESTS) begin

			diff = $signed(reciprocal)
				- $signed(expected_values[output_count]);

			if (diff < 0) begin
				diff = -diff;
			end

			if (expected_zero[output_count]) begin
				if (div_zero === 1'b1 && reciprocal === '0) begin
					$display("%s PASS: reciprocal = %0d, cycle = %0d",
						test_names[output_count],
						reciprocal,
						cycle_count);
				end
				else begin
					$error("%s FAIL: reciprocal = %0d, div_zero = %0b",
						test_names[output_count],
						reciprocal,
						div_zero);
				end
			end
			else if (div_zero !== 1'b0) begin
				$error("%s FAIL: unexpected divide by zero",
					test_names[output_count]);
			end
			else if (diff <= TOLERANCE) begin
				$display("%s PASS: reciprocal = %0d, expected = %0d, cycle = %0d",
					test_names[output_count],
					reciprocal,
					expected_values[output_count],
					cycle_count);
			end
			else begin
				$error("%s FAIL: reciprocal = %0d expected = %0d diff = %0d",
					test_names[output_count],
					reciprocal,
					expected_values[output_count],
					diff);
			end

			// Back-to-back outputs should prove II = 1
			if (output_count > 0) begin
				if (cycle_count != last_output_cycle + 1) begin
					$error("Pipeline gap detected between outputs");
				end
			end

			last_output_cycle = cycle_count;
			output_count = output_count + 1;
		end
	end


	initial begin
		clk = 1'b0;
		n_rst = 1'b0;
		in_valid = 1'b0;
		denominator = '0;
		stage = "Reset";

		input_count = 0;
		output_count = 0;
		cycle_count = 0;
		last_output_cycle = -1;

		// Reset
		repeat (2) @(posedge clk);
		@(negedge clk);
		n_rst = 1'b1;

		// Inputs are Q format with 8 fractional bits
		// Outputs use 20 fractional bits

		// 1 / 1 = 1
		send_test(
			24'sd256,
			32'sd1048576,
			1'b0,
			"Test 1: 1 / 1"
		);

		// 1 / 2 = 0.5
		send_test(
			24'sd512,
			32'sd524288,
			1'b0,
			"Test 2: 1 / 2"
		);

		// 1 / 0.5 = 2
		send_test(
			24'sd128,
			32'sd2097152,
			1'b0,
			"Test 3: 1 / 0.5"
		);

		// 1 / 1.5 = 0.666...
		send_test(
			24'sd384,
			32'sd699051,
			1'b0,
			"Test 4: 1 / 1.5"
		);

		// 1 / -2 = -0.5
		send_test(
			-24'sd512,
			-32'sd524288,
			1'b0,
			"Test 5: 1 / -2"
		);

		// 1 / 4 = 0.25
		send_test(
			24'sd1024,
			32'sd262144,
			1'b0,
			"Test 6: 1 / 4"
		);

		// 1 / 10 = 0.1
		send_test(
			24'sd2560,
			32'sd104858,
			1'b0,
			"Test 7: 1 / 10"
		);

		// 1 / 1000 = 0.001
		send_test(
			24'sd256000,
			32'sd1049,
			1'b0,
			"Test 8: 1 / 1000"
		);

		// Divide by zero
		send_test(
			24'sd0,
			32'sd0,
			1'b1,
			"Test 9: Divide by Zero"
		);

		// Stop sending data and drain pipeline
		@(negedge clk);
		in_valid = 1'b0;
		denominator = '0;
		stage = "Drain Pipeline";

		wait (output_count == NUM_TESTS);

		repeat (2) @(posedge clk);

		$display("All reciprocal pipeline tests completed.");
		$display("Back-to-back outputs confirm II = 1.");

		$finish;
	end

endmodule