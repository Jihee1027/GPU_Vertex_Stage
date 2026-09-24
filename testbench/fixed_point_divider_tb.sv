`timescale 1ns/1ns

module fixed_point_divider_tb;

	parameter DATA_W = 24;
	parameter FRAC_W = 8;

	localparam EXT_W = DATA_W + FRAC_W;

	logic clk, n_rst, start;
	logic signed [DATA_W-1:0] numerator, denominator;
	logic signed [DATA_W-1:0] quotient;
	logic div_zero, busy, done;

	string stage;

	fixed_point_divider #(
		.DATA_W(DATA_W),
		.FRAC_W(FRAC_W)
	) DUT (
		.clk(clk),
		.n_rst(n_rst),
		.start(start),
		.numerator(numerator),
		.denominator(denominator),
		.quotient(quotient),
		.div_zero(div_zero),
		.busy(busy),
		.done(done)
	);

	// 125 MHz clock
	always #4 clk = ~clk;

	task run_test(
		input logic signed [DATA_W-1:0] test_numerator,
		input logic signed [DATA_W-1:0] test_denominator,
		input logic signed [DATA_W-1:0] expected,
		input logic expected_div_zero,
		input string test_name
	);

		integer cycles;

		begin
			@(negedge clk);

			stage = test_name;
			numerator = test_numerator;
			denominator = test_denominator;
			start = 1'b1;

			@(negedge clk);
			start = 1'b0;

			cycles = 0;

			// Wait for division and finalize
			while (!done && cycles < EXT_W + 6) begin
				@(negedge clk);
				cycles = cycles + 1;
			end

			if (!done) begin
				$error("%s FAIL: timed out", stage);
			end
			else if (quotient === expected && div_zero === expected_div_zero) begin
				$display("%s PASS: quotient = %0d, cycles = %0d",
					stage, quotient, cycles);
			end
			else begin
				$error("%s FAIL: quotient = %0d expected = %0d, div_zero = %0b expected = %0b",
					stage,
					quotient, expected,
					div_zero, expected_div_zero);
			end
		end
	endtask

	initial begin
		clk = 1'b0;
		n_rst = 1'b0;
		start = 1'b0;
		numerator = '0;
		denominator = '0;
		stage = "Reset";

		// Reset
		repeat (2) @(posedge clk);
		@(negedge clk);
		n_rst = 1'b1;

		// 4 / 2 = 2
		run_test(24'sd1024, 24'sd512, 24'sd512, 1'b0, "Test 1: 4 / 2");

		// 1 / 2 = 0.5
		run_test(24'sd256, 24'sd512, 24'sd128, 1'b0, "Test 2: 1 / 2");

		// -4 / 2 = -2
		run_test(-24'sd1024, 24'sd512, -24'sd512, 1'b0, "Test 3: -4 / 2");

		// 1 / -2 = -0.5
		run_test(24'sd256, -24'sd512, -24'sd128, 1'b0, "Test 4: 1 / -2");

		// 3 / 2 = 1.5
		run_test(24'sd768, 24'sd512, 24'sd384, 1'b0, "Test 5: 3 / 2");

		// Divide by zero
		run_test(24'sd256, 24'sd0, 24'sd0, 1'b1, "Test 6: Divide by Zero");

		// Positive saturation
		run_test(24'sh7FFFFF, 24'sd128, 24'sh7FFFFF, 1'b0, "Test 7: Positive Saturation");

		// Negative saturation
		run_test(24'sh800000, 24'sd128, 24'sh800000, 1'b0, "Test 8: Negative Saturation");

		$display("All fixed point divider tests completed.");
		$finish;
	end

endmodule