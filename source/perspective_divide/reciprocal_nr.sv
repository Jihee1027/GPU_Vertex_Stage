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

	localparam NORMAL_FRAC = DATA_W - 1;
	localparam INDEX_W = $clog2(DATA_W);
	localparam SCALE_OFFSET = RECIP_FRAC - NORMAL_FRAC + FRAC_W;
	logic [DATA_W-1:0] abs_value;
	logic [INDEX_W-1:0] highest_bit;
	logic [DATA_W-1:0] next_normalized;
	logic signed [7:0] next_shift_amount;
	logic [DATA_W-1:0] normalized;
	logic signed [7:0] shift_amount;
	logic input_sign;
	logic input_zero;
	logic input_valid;
	logic [DATA_W-1:0] next_start_value;
	logic [DATA_W-1:0] start_value;
	logic [DATA_W-1:0] nr_value;
	logic signed [7:0] nr_shift;
	logic nr_sign;
	logic nr_zero;
	logic nr_valid;
	logic [DATA_W-1:0] first_value;
	logic [DATA_W-1:0] first_result;
	logic signed [7:0] first_shift;
	logic first_sign;
	logic first_zero;
	logic first_valid;
	logic [DATA_W-1:0] final_result;
	logic signed [7:0] final_shift;
	logic final_sign;
	logic final_zero;
	logic final_valid;
	logic [RECIP_W-1:0] final_result_full;
	logic [RECIP_W-1:0] scaled_result;
	logic signed [RECIP_W-1:0] next_reciprocal;
	logic next_out_valid;
	logic next_div_zero;

	// Normalize denominator
	always_comb begin : Normalize_Logic
		// Remove sign
		if (denominator[DATA_W-1]) begin
			abs_value = -denominator;
		end else begin
			abs_value = denominator;
		end
		// Find highest set bit
		highest_bit = '0;
		for (int i = 0; i < DATA_W; i++) begin
			if (abs_value[i]) begin
				highest_bit = i;
			end
		end
		// Normalize into [1, 2)
		next_normalized =
			abs_value << (NORMAL_FRAC - highest_bit);
		// Save shift needed at the end
		next_shift_amount =
			SCALE_OFFSET - $signed({1'b0, highest_bit});
	end

	always_ff @(posedge clk or negedge n_rst) begin : Normalize_Register
		if (!n_rst) begin
			normalized <= '0;
			shift_amount <= '0;
			input_sign <= 1'b0;
			input_zero <= 1'b0;
			input_valid <= 1'b0;
		end else begin
			normalized <= next_normalized;
			shift_amount <= next_shift_amount;
			input_sign <= denominator[DATA_W-1];
			input_zero <= (denominator == 0);
			input_valid <= in_valid;
		end
	end

	// Select starting reciprocal value
	always_comb begin : Start_Value_Logic
		case (normalized[DATA_W-2 -: 4])
			4'h0: next_start_value = 24'h7C1F08;
			4'h1: next_start_value = 24'h750750;
			4'h2: next_start_value = 24'h6EB3E4;
			4'h3: next_start_value = 24'h690690;
			4'h4: next_start_value = 24'h63E706;
			4'h5: next_start_value = 24'h5F417D;
			4'h6: next_start_value = 24'h5B05B0;
			4'h7: next_start_value = 24'h572621;
			4'h8: next_start_value = 24'h539783;
			4'h9: next_start_value = 24'h505050;
			4'hA: next_start_value = 24'h4D4874;
			4'hB: next_start_value = 24'h4A7905;
			4'hC: next_start_value = 24'h47DC12;
			4'hD: next_start_value = 24'h456C79;
			4'hE: next_start_value = 24'h4325C5;
			4'hF: next_start_value = 24'h410410;

			default: next_start_value = 24'h400000;
		endcase
	end

	always_ff @(posedge clk or negedge n_rst) begin : Start_Value_Register
		if (!n_rst) begin
			start_value <= '0;
			nr_value <= '0;
			nr_shift <= '0;
			nr_sign <= 1'b0;
			nr_zero <= 1'b0;
			nr_valid <= 1'b0;
		end else begin
			start_value <= next_start_value;
			nr_value <= normalized;
			nr_shift <= shift_amount;
			nr_sign <= input_sign;
			nr_zero <= input_zero;
			nr_valid <= input_valid;
		end
	end

	// First Newton-Raphson iteration: result = guess * (2 - value * guess)
	nr_iteration #(
		.DATA_W(DATA_W)
	) FIRST_ITERATION (
		.clk(clk),
		.n_rst(n_rst),
		.in_valid(nr_valid),
		.value_in(nr_value),
		.guess_in(start_value),
		.shift_in(nr_shift),
		.sign_in(nr_sign),
		.zero_in(nr_zero),
		.out_valid(first_valid),
		.value_out(first_value),
		.result_out(first_result),
		.shift_out(first_shift),
		.sign_out(first_sign),
		.zero_out(first_zero)
	);

	// Second Newton-Raphson iteration
	nr_iteration #(
		.DATA_W(DATA_W)
	) SECOND_ITERATION (
		.clk(clk),
		.n_rst(n_rst),
		.in_valid(first_valid),
		.value_in(first_value),
		.guess_in(first_result),
		.shift_in(first_shift),
		.sign_in(first_sign),
		.zero_in(first_zero),
		.out_valid(final_valid),
		.value_out(),
		.result_out(final_result),
		.shift_out(final_shift),
		.sign_out(final_sign),
		.zero_out(final_zero)
	);

	// Restore scale and sign
	always_comb begin : Output_Logic
		// Extend result to output width
		final_result_full =
			{{(RECIP_W-DATA_W){1'b0}}, final_result};
		// Restore original scale
		if (final_shift >= 0) begin
			scaled_result =
				final_result_full << final_shift;
		end else begin
			scaled_result =
				final_result_full >> (-final_shift);
		end
		// Restore sign
		if (final_zero) begin
			next_reciprocal = '0;
		end else if (final_sign) begin
			next_reciprocal = -$signed(scaled_result);
		end else begin
			next_reciprocal = $signed(scaled_result);
		end
		next_out_valid = final_valid;
		next_div_zero = final_zero;
	end

	always_ff @(posedge clk or negedge n_rst) begin : Output_Register
		if (!n_rst) begin
			reciprocal <= '0;
			out_valid <= 1'b0;
			div_zero <= 1'b0;
		end else begin
			reciprocal <= next_reciprocal;
			out_valid <= next_out_valid;
			div_zero <= next_div_zero;
		end
	end

endmodule