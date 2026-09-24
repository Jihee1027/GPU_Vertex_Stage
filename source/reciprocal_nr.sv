module reciprocal_nr #(
	parameter DATA_W = 24,
	parameter FRAC_W = 8,
	parameter RECIP_W = 32,
	parameter RECIP_FRAC = 20
)(
	input logic clk,
	input logic n_rst,

	input logic in_valid,
	input logic signed [DATA_W-1:0] denominator,

	output logic out_valid,
	output logic signed [RECIP_W-1:0] reciprocal,
	output logic div_zero
);

	localparam MANT_W = 17;
	localparam MANT_FRAC = MANT_W - 1;

	localparam R_W = DATA_W;
	localparam R_FRAC = DATA_W - 1;

	localparam PROD_W = MANT_W + R_W;
	localparam INDEX_W = $clog2(DATA_W);

	localparam BASE_SHIFT = RECIP_FRAC - R_FRAC + FRAC_W;

	localparam logic [MANT_W:0] TWO_Q = {1'b1, {MANT_W{1'b0}}};

	logic [9:0] valid_pipe;
	logic [9:0] n_valid_pipe;

	logic [DATA_W-1:0] denominator_mag;
	logic [INDEX_W-1:0] msb_index;
	logic [DATA_W-1:0] normalized_full;
	logic [MANT_W-1:0] normalized_input;
	logic signed [7:0] scale_shift_input;


	logic [MANT_W-1:0] normalized_s0;
	logic [MANT_W-1:0] n_normalized_s0;
	logic sign_s0, n_sign_s0;
	logic zero_s0, n_zero_s0;
	logic signed [7:0] scale_shift_s0, n_scale_shift_s0;


	logic [MANT_W-1:0] normalized_s1;
	logic [MANT_W-1:0] n_normalized_s1;

	logic [R_W-1:0] r0_s1;
	logic [R_W-1:0] n_r0_s1;

	logic sign_s1, n_sign_s1;
	logic zero_s1, n_zero_s1;
	logic signed [7:0] scale_shift_s1, n_scale_shift_s1;


	logic [PROD_W-1:0] mr0_prod_s2;
	logic [PROD_W-1:0] n_mr0_prod_s2;

	logic [MANT_W-1:0] normalized_s2;
	logic [MANT_W-1:0] n_normalized_s2;

	logic [R_W-1:0] r0_s2;
	logic [R_W-1:0] n_r0_s2;

	logic sign_s2, n_sign_s2;
	logic zero_s2, n_zero_s2;
	logic signed [7:0] scale_shift_s2, n_scale_shift_s2;


	logic [MANT_W-1:0] error0_s3;
	logic [MANT_W-1:0] n_error0_s3;

	logic [MANT_W-1:0] normalized_s3;
	logic [MANT_W-1:0] n_normalized_s3;

	logic [R_W-1:0] r0_s3;
	logic [R_W-1:0] n_r0_s3;

	logic sign_s3, n_sign_s3;
	logic zero_s3, n_zero_s3;
	logic signed [7:0] scale_shift_s3, n_scale_shift_s3;


	logic [R_W-1:0] r1_s4;
	logic [R_W-1:0] n_r1_s4;

	logic [MANT_W-1:0] normalized_s4;
	logic [MANT_W-1:0] n_normalized_s4;

	logic sign_s4, n_sign_s4;
	logic zero_s4, n_zero_s4;
	logic signed [7:0] scale_shift_s4, n_scale_shift_s4;


	logic [PROD_W-1:0] mr1_prod_s5;
	logic [PROD_W-1:0] n_mr1_prod_s5;

	logic [R_W-1:0] r1_s5;
	logic [R_W-1:0] n_r1_s5;

	logic sign_s5, n_sign_s5;
	logic zero_s5, n_zero_s5;
	logic signed [7:0] scale_shift_s5, n_scale_shift_s5;


	logic [MANT_W-1:0] error1_s6;
	logic [MANT_W-1:0] n_error1_s6;

	logic [R_W-1:0] r1_s6;
	logic [R_W-1:0] n_r1_s6;

	logic sign_s6, n_sign_s6;
	logic zero_s6, n_zero_s6;
	logic signed [7:0] scale_shift_s6, n_scale_shift_s6;


	logic [R_W-1:0] r2_s7;
	logic [R_W-1:0] n_r2_s7;

	logic sign_s7, n_sign_s7;
	logic zero_s7, n_zero_s7;
	logic signed [7:0] scale_shift_s7, n_scale_shift_s7;


	logic [RECIP_W-1:0] reciprocal_mag_s8;
	logic [RECIP_W-1:0] n_reciprocal_mag_s8;

	logic sign_s8, n_sign_s8;
	logic zero_s8, n_zero_s8;


	logic signed [RECIP_W-1:0] n_reciprocal;
	logic n_div_zero;


	logic [MANT_W:0] mr0_scaled;
	logic [MANT_W:0] error0_comb;

	logic [PROD_W-1:0] r1_prod_comb;
	logic [R_W:0] r1_scaled_comb;

	logic [MANT_W:0] mr1_scaled;
	logic [MANT_W:0] error1_comb;

	logic [PROD_W-1:0] r2_prod_comb;
	logic [R_W:0] r2_scaled_comb;

	logic [RECIP_W-1:0] r2_extended;
	logic [RECIP_W-1:0] reciprocal_mag_comb;

	integer i;


	// Initial reciprocal estimate
	function automatic logic [R_W-1:0] seed_lookup(
		input logic [3:0] index
	);
		begin
			case (index)
				4'h0: seed_lookup = 24'h7C1F08;
				4'h1: seed_lookup = 24'h750750;
				4'h2: seed_lookup = 24'h6EB3E4;
				4'h3: seed_lookup = 24'h690690;
				4'h4: seed_lookup = 24'h63E706;
				4'h5: seed_lookup = 24'h5F417D;
				4'h6: seed_lookup = 24'h5B05B0;
				4'h7: seed_lookup = 24'h572621;
				4'h8: seed_lookup = 24'h539783;
				4'h9: seed_lookup = 24'h505050;
				4'hA: seed_lookup = 24'h4D4874;
				4'hB: seed_lookup = 24'h4A7905;
				4'hC: seed_lookup = 24'h47DC12;
				4'hD: seed_lookup = 24'h456C79;
				4'hE: seed_lookup = 24'h4325C5;
				4'hF: seed_lookup = 24'h410410;
				default: seed_lookup = 24'h400000;
			endcase
		end
	endfunction


	// Normalize denominator to [1, 2)
	always_comb begin
		if (denominator[DATA_W-1]) begin
			denominator_mag = -denominator;
		end
		else begin
			denominator_mag = denominator;
		end

		msb_index = '0;

		for (i = 0; i < DATA_W; i = i + 1) begin
			if (denominator_mag[i]) begin
				msb_index = i;
			end
		end

		normalized_full = denominator_mag << ((DATA_W - 1) - msb_index);
		normalized_input = normalized_full[DATA_W-1 -: MANT_W];

		scale_shift_input = BASE_SHIFT - $signed({1'b0, msb_index});
	end


	// First Newton-Raphson iteration
	always_comb begin
		mr0_scaled = mr0_prod_s2 >> R_FRAC;
		error0_comb = TWO_Q - mr0_scaled;

		r1_prod_comb = r0_s3 * error0_s3;
		r1_scaled_comb = r1_prod_comb >> MANT_FRAC;
	end


	// Second Newton-Raphson iteration
	always_comb begin
		mr1_scaled = mr1_prod_s5 >> R_FRAC;
		error1_comb = TWO_Q - mr1_scaled;

		r2_prod_comb = r1_s6 * error1_s6;
		r2_scaled_comb = r2_prod_comb >> MANT_FRAC;
	end


	// Restore reciprocal scale
	always_comb begin
		r2_extended = {{(RECIP_W-R_W){1'b0}}, r2_s7};

		if (scale_shift_s7 >= 0) begin
			reciprocal_mag_comb = r2_extended << scale_shift_s7;
		end
		else begin
			reciprocal_mag_comb = r2_extended >> (-scale_shift_s7);
		end
	end


	// Next pipeline values
	always_comb begin
		n_valid_pipe = {valid_pipe[8:0], in_valid};

		// Stage 0
		n_normalized_s0 = normalized_input;
		n_sign_s0 = denominator[DATA_W-1];
		n_zero_s0 = (denominator == 0);
		n_scale_shift_s0 = scale_shift_input;

		// Stage 1
		n_normalized_s1 = normalized_s0;
		n_r0_s1 = seed_lookup(normalized_s0[MANT_W-2 -: 4]);
		n_sign_s1 = sign_s0;
		n_zero_s1 = zero_s0;
		n_scale_shift_s1 = scale_shift_s0;

		// Stage 2
		n_mr0_prod_s2 = normalized_s1 * r0_s1;
		n_normalized_s2 = normalized_s1;
		n_r0_s2 = r0_s1;
		n_sign_s2 = sign_s1;
		n_zero_s2 = zero_s1;
		n_scale_shift_s2 = scale_shift_s1;

		// Stage 3
		n_error0_s3 = error0_comb[MANT_W-1:0];
		n_normalized_s3 = normalized_s2;
		n_r0_s3 = r0_s2;
		n_sign_s3 = sign_s2;
		n_zero_s3 = zero_s2;
		n_scale_shift_s3 = scale_shift_s2;

		// Stage 4
		n_r1_s4 = r1_scaled_comb[R_W-1:0];
		n_normalized_s4 = normalized_s3;
		n_sign_s4 = sign_s3;
		n_zero_s4 = zero_s3;
		n_scale_shift_s4 = scale_shift_s3;

		// Stage 5
		n_mr1_prod_s5 = normalized_s4 * r1_s4;
		n_r1_s5 = r1_s4;
		n_sign_s5 = sign_s4;
		n_zero_s5 = zero_s4;
		n_scale_shift_s5 = scale_shift_s4;

		// Stage 6
		n_error1_s6 = error1_comb[MANT_W-1:0];
		n_r1_s6 = r1_s5;
		n_sign_s6 = sign_s5;
		n_zero_s6 = zero_s5;
		n_scale_shift_s6 = scale_shift_s5;

		// Stage 7
		n_r2_s7 = r2_scaled_comb[R_W-1:0];
		n_sign_s7 = sign_s6;
		n_zero_s7 = zero_s6;
		n_scale_shift_s7 = scale_shift_s6;

		// Stage 8
		n_reciprocal_mag_s8 = reciprocal_mag_comb;
		n_sign_s8 = sign_s7;
		n_zero_s8 = zero_s7;

		// Stage 9
		n_div_zero = zero_s8;

		if (zero_s8) begin
			n_reciprocal = '0;
		end
		else if (sign_s8) begin
			n_reciprocal = -$signed(reciprocal_mag_s8);
		end
		else begin
			n_reciprocal = $signed(reciprocal_mag_s8);
		end
	end


	assign out_valid = valid_pipe[9];


	// Pipeline registers
	always_ff @(posedge clk, negedge n_rst) begin
		if (!n_rst) begin
			valid_pipe <= '0;

			normalized_s0 <= '0;
			sign_s0 <= 1'b0;
			zero_s0 <= 1'b0;
			scale_shift_s0 <= '0;

			normalized_s1 <= '0;
			r0_s1 <= '0;
			sign_s1 <= 1'b0;
			zero_s1 <= 1'b0;
			scale_shift_s1 <= '0;

			mr0_prod_s2 <= '0;
			normalized_s2 <= '0;
			r0_s2 <= '0;
			sign_s2 <= 1'b0;
			zero_s2 <= 1'b0;
			scale_shift_s2 <= '0;

			error0_s3 <= '0;
			normalized_s3 <= '0;
			r0_s3 <= '0;
			sign_s3 <= 1'b0;
			zero_s3 <= 1'b0;
			scale_shift_s3 <= '0;

			r1_s4 <= '0;
			normalized_s4 <= '0;
			sign_s4 <= 1'b0;
			zero_s4 <= 1'b0;
			scale_shift_s4 <= '0;

			mr1_prod_s5 <= '0;
			r1_s5 <= '0;
			sign_s5 <= 1'b0;
			zero_s5 <= 1'b0;
			scale_shift_s5 <= '0;

			error1_s6 <= '0;
			r1_s6 <= '0;
			sign_s6 <= 1'b0;
			zero_s6 <= 1'b0;
			scale_shift_s6 <= '0;

			r2_s7 <= '0;
			sign_s7 <= 1'b0;
			zero_s7 <= 1'b0;
			scale_shift_s7 <= '0;

			reciprocal_mag_s8 <= '0;
			sign_s8 <= 1'b0;
			zero_s8 <= 1'b0;

			reciprocal <= '0;
			div_zero <= 1'b0;
		end
		else begin
			valid_pipe <= n_valid_pipe;

			normalized_s0 <= n_normalized_s0;
			sign_s0 <= n_sign_s0;
			zero_s0 <= n_zero_s0;
			scale_shift_s0 <= n_scale_shift_s0;

			normalized_s1 <= n_normalized_s1;
			r0_s1 <= n_r0_s1;
			sign_s1 <= n_sign_s1;
			zero_s1 <= n_zero_s1;
			scale_shift_s1 <= n_scale_shift_s1;

			mr0_prod_s2 <= n_mr0_prod_s2;
			normalized_s2 <= n_normalized_s2;
			r0_s2 <= n_r0_s2;
			sign_s2 <= n_sign_s2;
			zero_s2 <= n_zero_s2;
			scale_shift_s2 <= n_scale_shift_s2;

			error0_s3 <= n_error0_s3;
			normalized_s3 <= n_normalized_s3;
			r0_s3 <= n_r0_s3;
			sign_s3 <= n_sign_s3;
			zero_s3 <= n_zero_s3;
			scale_shift_s3 <= n_scale_shift_s3;

			r1_s4 <= n_r1_s4;
			normalized_s4 <= n_normalized_s4;
			sign_s4 <= n_sign_s4;
			zero_s4 <= n_zero_s4;
			scale_shift_s4 <= n_scale_shift_s4;

			mr1_prod_s5 <= n_mr1_prod_s5;
			r1_s5 <= n_r1_s5;
			sign_s5 <= n_sign_s5;
			zero_s5 <= n_zero_s5;
			scale_shift_s5 <= n_scale_shift_s5;

			error1_s6 <= n_error1_s6;
			r1_s6 <= n_r1_s6;
			sign_s6 <= n_sign_s6;
			zero_s6 <= n_zero_s6;
			scale_shift_s6 <= n_scale_shift_s6;

			r2_s7 <= n_r2_s7;
			sign_s7 <= n_sign_s7;
			zero_s7 <= n_zero_s7;
			scale_shift_s7 <= n_scale_shift_s7;

			reciprocal_mag_s8 <= n_reciprocal_mag_s8;
			sign_s8 <= n_sign_s8;
			zero_s8 <= n_zero_s8;

			reciprocal <= n_reciprocal;
			div_zero <= n_div_zero;
		end
	end

endmodule