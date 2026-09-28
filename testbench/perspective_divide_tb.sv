`timescale 1ns/1ns

module perspective_divide_tb;

	parameter DATA_W = 24;
	parameter FRAC_W = 8;
	parameter RECIP_W = 32;
	parameter RECIP_FRAC = 20;
	parameter NUM_TESTS = 14;

	logic clk, n_rst;
	logic in_valid;
	logic signed [DATA_W-1:0] x_clip, y_clip, z_clip, w_clip;
	logic signed [DATA_W-1:0] x_ndc, y_ndc, z_ndc;
	logic out_valid;
	logic div_zero;
	string stage;
	integer test_num;
	integer pass_count;
	integer fail_count;
	integer ii_fail;
	time last_output_time;

	perspective_divide #(
		.DATA_W(DATA_W),
		.FRAC_W(FRAC_W),
		.RECIP_W(RECIP_W),
		.RECIP_FRAC(RECIP_FRAC)
	) DUT (
		.clk(clk),
		.n_rst(n_rst),
		.in_valid(in_valid),
		.x_clip(x_clip),
		.y_clip(y_clip),
		.z_clip(z_clip),
		.w_clip(w_clip),
		.out_valid(out_valid),
		.x_ndc(x_ndc),
		.y_ndc(y_ndc),
		.z_ndc(z_ndc),
		.div_zero(div_zero)
	);

	// 125 MHz clock
	always #4 clk = ~clk;

	task automatic send_test(
		input logic signed [DATA_W-1:0] test_x,
		input logic signed [DATA_W-1:0] test_y,
		input logic signed [DATA_W-1:0] test_z,
		input logic signed [DATA_W-1:0] test_w,
		input string test_name
	);
		begin
			@(negedge clk);
			stage = test_name;
			x_clip = test_x;
			y_clip = test_y;
			z_clip = test_z;
			w_clip = test_w;
			in_valid = 1'b1;
		end
	endtask

	task automatic check_result(
		input string test_name,
		input integer expected_x,
		input integer expected_y,
		input integer expected_z,
		input integer tolerance,
		input logic expected_zero
	);
		begin
			if (
				$signed(x_ndc) >= expected_x - tolerance &&
				$signed(x_ndc) <= expected_x + tolerance &&
				$signed(y_ndc) >= expected_y - tolerance &&
				$signed(y_ndc) <= expected_y + tolerance &&
				$signed(z_ndc) >= expected_z - tolerance &&
				$signed(z_ndc) <= expected_z + tolerance &&
				div_zero == expected_zero
			) begin
				$display("%s PASS: x=%0d y=%0d z=%0d", test_name, x_ndc, y_ndc, z_ndc);
				pass_count = pass_count + 1;
			end
			else begin
				$display("%s FAIL: x=%0d y=%0d z=%0d div_zero=%0b", test_name, x_ndc, y_ndc, z_ndc, div_zero);
				$display("Expected: x=%0d y=%0d z=%0d tolerance=%0d", expected_x, expected_y, expected_z, tolerance);
				fail_count = fail_count + 1;
			end
		end
	endtask

	// Check outputs in order
	always @(negedge clk) begin
		if (out_valid) begin
			if (test_num > 0) begin
				if (($time - last_output_time) != 8) begin
					$display("II FAIL: output gap = %0t ns", $time - last_output_time);
					ii_fail = ii_fail + 1;
				end
			end
			last_output_time = $time;

			case (test_num)
				0: check_result("Test 1: Divide by 1", 256, 512, 768, 1, 0);
				1: check_result("Test 2: Divide by 2", 128, 256, 384, 1, 0);
				2: check_result("Test 3: Signed Values", -256, 128, -128, 1, 0);
				3: check_result("Test 4: Divide by 0.5", 256, 768, 1280, 1, 0);
				4: check_result("Test 5: Divide by Zero", 0, 0, 0, 0, 1);
				5: check_result("Test 6: Large Values", 64000, -128000, 192000, 4, 0);
				6: check_result("Test 7: Large Range", 3840000, -3072000, 2048000, 32, 0);
				7: check_result("Test 8: Saturation", 8388607, -8388608, 51200, 1, 0);
				8: check_result("Test 9: Divide by 3", 256, 512, -768, 2, 0);
				9: check_result("Test 10: Divide by 1.5", 512, -256, 128, 2, 0);
				10: check_result("Test 11: Negative W", -256, 512, -128, 2, 0);
				11: check_result("Test 12: Divide by 0.75", 512, 256, -1024, 2, 0);
				12: check_result("Test 13: Zero Vector", 0, 0, 0, 0, 0);
				13: check_result("Test 14: Small W", 65536, -65536, 32768, 4, 0);
				default: begin
					$display("Unexpected output");
					fail_count = fail_count + 1;
				end
			endcase

			test_num = test_num + 1;
		end
	end

	initial begin
		clk = 1'b0;
		n_rst = 1'b0;
		in_valid = 1'b0;
		x_clip = '0;
		y_clip = '0;
		z_clip = '0;
		w_clip = '0;
		stage = "Reset";
		test_num = 0;
		pass_count = 0;
		fail_count = 0;
		ii_fail = 0;
		last_output_time = 0;

		repeat (2) @(posedge clk);
		@(negedge clk);
		n_rst = 1'b1;

		send_test(24'sd256, 24'sd512, 24'sd768, 24'sd256, "Test 1");
		send_test(24'sd256, 24'sd512, 24'sd768, 24'sd512, "Test 2");
		send_test(-24'sd512, 24'sd256, -24'sd256, 24'sd512, "Test 3");
		send_test(24'sd128, 24'sd384, 24'sd640, 24'sd128, "Test 4");
		send_test(24'sd256, 24'sd512, 24'sd768, 24'sd0, "Test 5");
		send_test(24'sd256000, -24'sd512000, 24'sd768000, 24'sd1024, "Test 6");
		send_test(24'sd7680000, -24'sd6144000, 24'sd4096000, 24'sd512, "Test 7");
		send_test(24'sh7FFFFF, 24'sh800000, 24'sd25600, 24'sd128, "Test 8");

		// Non-power-of-two denominator
		send_test(24'sd768, 24'sd1536, -24'sd2304, 24'sd768, "Test 9");

		// w = 1.5
		send_test(24'sd768, -24'sd384, 24'sd192, 24'sd384, "Test 10");

		// Negative denominator
		send_test(24'sd512, -24'sd1024, 24'sd256, -24'sd512, "Test 11");

		// w = 0.75
		send_test(24'sd384, 24'sd192, -24'sd768, 24'sd192, "Test 12");

		// Zero x, y, z
		send_test(24'sd0, 24'sd0, 24'sd0, 24'sd768, "Test 13");

		// Smallest positive Q16.8 denominator: 1/256
		send_test(24'sd256, -24'sd256, 24'sd128, 24'sd1, "Test 14");

		@(negedge clk);
		in_valid = 1'b0;
		x_clip = '0;
		y_clip = '0;
		z_clip = '0;
		w_clip = '0;
		stage = "Drain Pipeline";

		repeat (25) @(negedge clk);

		$display("");
		$display("Perspective Divide Test Summary");
		$display("PASS = %0d", pass_count);
		$display("FAIL = %0d", fail_count);

		if (ii_fail == 0 && test_num == NUM_TESTS) begin
			$display("II = 1 PASS");
		end
		else begin
			$display("II = 1 FAIL");
		end

		if (pass_count == NUM_TESTS && fail_count == 0 && ii_fail == 0 && test_num == NUM_TESTS) begin
			$display("All perspective divide tests passed.");
		end
		else begin
			$display("Perspective divide testing FAILED.");
		end

		$finish;
	end

endmodule