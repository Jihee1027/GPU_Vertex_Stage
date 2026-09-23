`timescale 1ns/1ns

module row_mac_tb;

	localparam DATA_W = 24;

	logic signed [DATA_W-1:0] x;
	logic signed [DATA_W-1:0] y;
	logic signed [DATA_W-1:0] z;
	logic signed [DATA_W-1:0] w;

	logic signed [DATA_W-1:0] m0;
	logic signed [DATA_W-1:0] m1;
	logic signed [DATA_W-1:0] m2;
	logic signed [DATA_W-1:0] m3;

	logic signed [DATA_W-1:0] result;

	integer stage;

	row_mac DUT (
		.x(x),
		.y(y),
		.z(z),
		.w(w),
		.m0(m0),
		.m1(m1),
		.m2(m2),
		.m3(m3),
		.result(result)
	);

	task check_result(
		input logic signed [DATA_W-1:0] expected,
		input string test_name
	);
		begin
			#10;

			assert(result === expected)
				$display("Stage %0d PASS: %s", stage, test_name);
			else
				$error("Stage %0d FAIL: %s, result = %0d expected = %0d",
					stage, test_name, result, expected);
		end
	endtask

	initial begin
		stage = 0;

		x = '0;
		y = '0;
		z = '0;
		w = '0;

		m0 = '0;
		m1 = '0;
		m2 = '0;
		m3 = '0;

		#10;

		// 1 * 1 = 1
		stage = 1;

		x = 24'sd256;
		y = '0;
		z = '0;
		w = '0;

		m0 = 24'sd256;
		m1 = '0;
		m2 = '0;
		m3 = '0;

		check_result(24'sd256, "single multiply");


		// 1 + 2 + 3 + 1 = 7
		stage = 2;

		x = 24'sd256;
		y = 24'sd512;
		z = 24'sd768;
		w = 24'sd256;

		m0 = 24'sd256;
		m1 = 24'sd256;
		m2 = 24'sd256;
		m3 = 24'sd256;

		check_result(24'sd1792, "four value sum");


		// -2 + 3 - 1 + 1 = 1
		stage = 3;

		x = -24'sd512;
		y = 24'sd768;
		z = -24'sd256;
		w = 24'sd256;

		m0 = 24'sd256;
		m1 = 24'sd256;
		m2 = 24'sd256;
		m3 = 24'sd256;

		check_result(24'sd256, "signed values");


		// 0.5*2 + 1.5*0.5 = 1.75
		stage = 4;

		x = 24'sd128;
		y = 24'sd384;
		z = '0;
		w = '0;

		m0 = 24'sd512;
		m1 = 24'sd128;
		m2 = '0;
		m3 = '0;

		check_result(24'sd448, "fractional values");


		// positive saturation
		stage = 5;

		x = 24'sh7FFFFF;
		y = '0;
		z = '0;
		w = '0;

		m0 = 24'sd512;
		m1 = '0;
		m2 = '0;
		m3 = '0;

		check_result(24'sh7FFFFF, "positive saturation");


		$display("All row_mac tests completed.");
		$finish;
	end

endmodule