`timescale 1ns/1ns

module perspective_divide_tb;

	parameter DATA_W = 24;
	parameter FRAC_W = 8;
	parameter RECIP_W = 32;
	parameter RECIP_FRAC = 20;

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


	task send_test(
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


	// Check outputs in order
	always @(negedge clk) begin
		if (out_valid) begin

			// Check II = 1
			if (test_num > 0) begin
				if (($time - last_output_time) != 8) begin
					$display("II FAIL: output gap = %0t ns", $time - last_output_time);
					ii_fail = ii_fail + 1;
				end
			end

			last_output_time = $time;


			case (test_num)

				0: begin
					if (
						x_ndc >= 255 && x_ndc <= 256 &&
						y_ndc >= 511 && y_ndc <= 512 &&
						z_ndc >= 767 && z_ndc <= 768 &&
						div_zero == 0
					) begin
						$display("Test 1 PASS: x=%0d y=%0d z=%0d",
							x_ndc, y_ndc, z_ndc);
						pass_count = pass_count + 1;
					end
					else begin
						$display("Test 1 FAIL: x=%0d y=%0d z=%0d div_zero=%0b",
							x_ndc, y_ndc, z_ndc, div_zero);
						fail_count = fail_count + 1;
					end
				end


				1: begin
					if (
						x_ndc >= 127 && x_ndc <= 128 &&
						y_ndc >= 255 && y_ndc <= 256 &&
						z_ndc >= 383 && z_ndc <= 384 &&
						div_zero == 0
					) begin
						$display("Test 2 PASS: x=%0d y=%0d z=%0d",
							x_ndc, y_ndc, z_ndc);
						pass_count = pass_count + 1;
					end
					else begin
						$display("Test 2 FAIL: x=%0d y=%0d z=%0d div_zero=%0b",
							x_ndc, y_ndc, z_ndc, div_zero);
						fail_count = fail_count + 1;
					end
				end


				2: begin
					if (
						x_ndc >= -257 && x_ndc <= -255 &&
						y_ndc >= 127 && y_ndc <= 129 &&
						z_ndc >= -129 && z_ndc <= -127 &&
						div_zero == 0
					) begin
						$display("Test 3 PASS: x=%0d y=%0d z=%0d",
							x_ndc, y_ndc, z_ndc);
						pass_count = pass_count + 1;
					end
					else begin
						$display("Test 3 FAIL: x=%0d y=%0d z=%0d div_zero=%0b",
							x_ndc, y_ndc, z_ndc, div_zero);
						fail_count = fail_count + 1;
					end
				end


				3: begin
					if (
						x_ndc >= 255 && x_ndc <= 256 &&
						y_ndc >= 767 && y_ndc <= 768 &&
						z_ndc >= 1279 && z_ndc <= 1280 &&
						div_zero == 0
					) begin
						$display("Test 4 PASS: x=%0d y=%0d z=%0d",
							x_ndc, y_ndc, z_ndc);
						pass_count = pass_count + 1;
					end
					else begin
						$display("Test 4 FAIL: x=%0d y=%0d z=%0d div_zero=%0b",
							x_ndc, y_ndc, z_ndc, div_zero);
						fail_count = fail_count + 1;
					end
				end


				4: begin
					if (
						x_ndc == 0 &&
						y_ndc == 0 &&
						z_ndc == 0 &&
						div_zero == 1
					) begin
						$display("Test 5 PASS: divide by zero");
						pass_count = pass_count + 1;
					end
					else begin
						$display("Test 5 FAIL: x=%0d y=%0d z=%0d div_zero=%0b",
							x_ndc, y_ndc, z_ndc, div_zero);
						fail_count = fail_count + 1;
					end
				end


				5: begin
					if (
						x_ndc >= 63996 && x_ndc <= 64004 &&
						y_ndc >= -128004 && y_ndc <= -127996 &&
						z_ndc >= 191996 && z_ndc <= 192004 &&
						div_zero == 0
					) begin
						$display("Test 6 PASS: x=%0d y=%0d z=%0d",
							x_ndc, y_ndc, z_ndc);
						pass_count = pass_count + 1;
					end
					else begin
						$display("Test 6 FAIL: x=%0d y=%0d z=%0d div_zero=%0b",
							x_ndc, y_ndc, z_ndc, div_zero);
						fail_count = fail_count + 1;
					end
				end


				6: begin
					if (
						x_ndc >= 3839968 && x_ndc <= 3840032 &&
						y_ndc >= -3072032 && y_ndc <= -3071968 &&
						z_ndc >= 2047968 && z_ndc <= 2048032 &&
						div_zero == 0
					) begin
						$display("Test 7 PASS: x=%0d y=%0d z=%0d",
							x_ndc, y_ndc, z_ndc);
						pass_count = pass_count + 1;
					end
					else begin
						$display("Test 7 FAIL: x=%0d y=%0d z=%0d div_zero=%0b",
							x_ndc, y_ndc, z_ndc, div_zero);
						fail_count = fail_count + 1;
					end
				end


				7: begin
					if (
						x_ndc == 24'sh7FFFFF &&
						y_ndc == 24'sh800000 &&
						z_ndc >= 51199 && z_ndc <= 51200 &&
						div_zero == 0
					) begin
						$display("Test 8 PASS: x=%0d y=%0d z=%0d",
							x_ndc, y_ndc, z_ndc);
						pass_count = pass_count + 1;
					end
					else begin
						$display("Test 8 FAIL: x=%0d y=%0d z=%0d div_zero=%0b",
							x_ndc, y_ndc, z_ndc, div_zero);
						fail_count = fail_count + 1;
					end
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


		send_test(
			24'sd256,
			24'sd512,
			24'sd768,
			24'sd256,
			"Test 1: Divide by 1"
		);

		send_test(
			24'sd256,
			24'sd512,
			24'sd768,
			24'sd512,
			"Test 2: Divide by 2"
		);

		send_test(
			-24'sd512,
			24'sd256,
			-24'sd256,
			24'sd512,
			"Test 3: Signed Values"
		);

		send_test(
			24'sd128,
			24'sd384,
			24'sd640,
			24'sd128,
			"Test 4: Fractional Values"
		);

		send_test(
			24'sd256,
			24'sd512,
			24'sd768,
			24'sd0,
			"Test 5: Divide by Zero"
		);

		send_test(
			24'sd256000,
			-24'sd512000,
			24'sd768000,
			24'sd1024,
			"Test 6: Large Values"
		);

		send_test(
			24'sd7680000,
			-24'sd6144000,
			24'sd4096000,
			24'sd512,
			"Test 7: Large Range"
		);

		send_test(
			24'sh7FFFFF,
			24'sh800000,
			24'sd25600,
			24'sd128,
			"Test 8: Saturation"
		);


		@(negedge clk);

		in_valid = 1'b0;
		x_clip = '0;
		y_clip = '0;
		z_clip = '0;
		w_clip = '0;

		stage = "Drain Pipeline";


		repeat (20) @(negedge clk);


		$display("");
		$display("Perspective Divide Test Summary");
		$display("PASS = %0d", pass_count);
		$display("FAIL = %0d", fail_count);


		if (ii_fail == 0 && test_num == 8) begin
			$display("II = 1 PASS");
		end
		else begin
			$display("II = 1 FAIL");
		end


		if (
			pass_count == 8 &&
			fail_count == 0 &&
			ii_fail == 0 &&
			test_num == 8
		) begin
			$display("All perspective divide tests passed.");
		end
		else begin
			$display("Perspective divide testing FAILED.");
		end


		$finish;
	end

endmodule