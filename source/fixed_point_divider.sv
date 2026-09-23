module fixed_point_divider #(
	parameter DATA_W = 24,
	parameter FRAC_W = 8
)(
	input logic signed [DATA_W-1:0] numerator,
	input logic signed [DATA_W-1:0] denominator,

	output logic signed [DATA_W-1:0] quotient,
	output logic div_zero
);

	localparam EXT_W = DATA_W + FRAC_W;

	logic signed [EXT_W-1:0] scaled_num;
	logic signed [EXT_W-1:0] divided;

	localparam logic signed [EXT_W-1:0] MAX_VAL = (1 << (DATA_W - 1)) - 1;
	localparam logic signed [EXT_W-1:0] MIN_VAL = -(1 << (DATA_W - 1));

	assign scaled_num = {{FRAC_W{numerator[DATA_W-1]}}, numerator} <<< FRAC_W;
	assign divided = scaled_num / denominator;

	always_comb begin
		div_zero = 1'b0;
		quotient = '0;

		if (denominator == 0) begin
			div_zero = 1'b1;
		end
		else if (divided > MAX_VAL) begin
			quotient = MAX_VAL[DATA_W-1:0];
		end
		else if (divided < MIN_VAL) begin
			quotient = MIN_VAL[DATA_W-1:0];
		end
		else begin
			quotient = divided[DATA_W-1:0];
		end
	end

endmodule