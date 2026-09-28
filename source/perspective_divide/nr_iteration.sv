// multiplly -> adjust -> multiply -> result for reciprocal
module nr_iteration #(
	parameter DATA_W = 24
)(
	input logic clk,
	input logic n_rst,
	input logic in_valid,
	input logic [DATA_W-1:0] value_in,
	input logic [DATA_W-1:0] guess_in,
	input logic signed [7:0] shift_in,
	input logic sign_in,
	input logic zero_in,
	output logic out_valid,
	output logic [DATA_W-1:0] value_out,
	output logic [DATA_W-1:0] result_out,
	output logic signed [7:0] shift_out,
	output logic sign_out,
	output logic zero_out
);
	localparam NORMAL_FRAC = DATA_W - 1;
	localparam logic [DATA_W:0] TWO = {1'b1, {DATA_W{1'b0}}};
	logic [(2*DATA_W)-1:0] first_product;
	logic [DATA_W:0] first_product_scaled;
	logic [DATA_W:0] adjust_value;
	logic [(2*DATA_W):0] second_product;
	logic [DATA_W-1:0] guess_delay [0:1];
	logic [DATA_W-1:0] value_delay [0:3];
	logic signed [7:0] shift_delay [0:3];
	logic [3:0] valid_delay;
	logic [3:0] sign_delay;
	logic [3:0] zero_delay;
	integer i;

	// First multiply: value * current guess
	nr_multiplier #(
		.A_W(DATA_W),
		.B_W(DATA_W)
	) FIRST_MULTIPLY (
		.clk(clk),
		.n_rst(n_rst),
		.a(value_in),
		.b(guess_in),
		.product(first_product)
	);

	// Newton-Raphson adjustment
	// adjust = 2 - (value * guess)
	always_comb begin : Adjust_Logic
		first_product_scaled =
			first_product >> NORMAL_FRAC;

		adjust_value =
			TWO - first_product_scaled;
	end

	// Second multiply: guess * adjustment
	nr_multiplier #(
		.A_W(DATA_W),
		.B_W(DATA_W + 1)
	) SECOND_MULTIPLY (
		.clk(clk),
		.n_rst(n_rst),
		.a(guess_delay[1]),
		.b(adjust_value),
		.product(second_product)
	);

	// Convert result back to Q1.23
	always_comb begin : Result_Logic
		result_out =
			second_product >> NORMAL_FRAC;
	end

	// Delay values to match multiplier pipeline
	always_ff @(posedge clk or negedge n_rst) begin : Delay_Register
		if (!n_rst) begin
			guess_delay[0] <= '0;
			guess_delay[1] <= '0;
			for (i = 0; i < 4; i = i + 1) begin
				value_delay[i] <= '0;
				shift_delay[i] <= '0;
			end
			valid_delay <= '0;
			sign_delay <= '0;
			zero_delay <= '0;
		end
		else begin
			guess_delay[0] <= guess_in;
			guess_delay[1] <= guess_delay[0];
			value_delay[0] <= value_in;
			shift_delay[0] <= shift_in;
			for (i = 1; i < 4; i = i + 1) begin
				value_delay[i] <= value_delay[i-1];
				shift_delay[i] <= shift_delay[i-1];
			end
			valid_delay <= {valid_delay[2:0], in_valid};
			sign_delay <= {sign_delay[2:0], sign_in};
			zero_delay <= {zero_delay[2:0], zero_in};
		end
	end

	assign value_out = value_delay[3];
	assign shift_out = shift_delay[3];
	assign out_valid = valid_delay[3];
	assign sign_out = sign_delay[3];
	assign zero_out = zero_delay[3];

endmodule