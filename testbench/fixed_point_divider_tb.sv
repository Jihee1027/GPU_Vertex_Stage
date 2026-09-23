`timescale 1ns/1ns

module fixed_point_divider_tb;

	parameter DATA_W = 24;

	logic signed [DATA_W-1:0] numerator;
	logic signed [DATA_W-1:0] denominator;

	logic signed [DATA_W-1:0] quotient;
	logic div_zero;

	integer stage;

	fixed_point_divider DUT (
		.numerator(numerator),
		.denominator(denominator),
		.quotient(quotient),
		.div_zero(div_zero)
	);

	task check_result(
		input logic signed [DATA_W-1:0] expected,
		input logic expected_div_zero,
		input string test_name
	);
		begin
			#10;

			assert(quotient === expected && div_zero === expected_div_zero)
				$display("Stage %0d PASS: %s", stage, test_name);
			else
				$error("Stage %0d FAIL: %s, quotient = %0d expected = %0d, div_zero = %0b",
					stage, test_name, quotient, expected, div_zero);
		end
	endtask

	initial begin
		stage = 0;
		numerator = '0;
		denominator = '0;
		#10;

		// 4 / 2 = 2
		stage = 1;
		numerator = 24'sd1024;
		denominator = 24'sd512;
		check_result(24'sd512, 1'b0, "4 / 2");

		// 1 / 2 = 0.5
		stage = 2;
		numerator = 24'sd256;
		denominator = 24'sd512;
		check_result(24'sd128, 1'b0, "1 / 2");

		// -4 / 2 = -2
		stage = 3;
		numerator = -24'sd1024;
		denominator = 24'sd512;
		check_result(-24'sd512, 1'b0, "-4 / 2");

		// 1 / -2 = -0.5
		stage = 4;
		numerator = 24'sd256;
		denominator = -24'sd512;
		check_result(-24'sd128, 1'b0, "1 / -2");

		// 3 / 2 = 1.5
		stage = 5;
		numerator = 24'sd768;
		denominator = 24'sd512;
		check_result(24'sd384, 1'b0, "3 / 2");

		// divide by zero
		stage = 6;
		numerator = 24'sd256;
		denominator = '0;
		check_result(24'sd0, 1'b1, "divide by zero");

		// positive saturation
		stage = 7;
		numerator = 24'sh7FFFFF;
		denominator = 24'sd128;
		check_result(24'sh7FFFFF, 1'b0, "positive saturation");

		// negative saturation
		stage = 8;
		numerator = -24'sd8388608;
		denominator = 24'sd128;
		check_result(24'sh800000, 1'b0, "negative saturation");

		$display("All tests completed.");
		$finish;
	end

endmodule