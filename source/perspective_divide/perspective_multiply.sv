// x,y,z * 1/w

module perspective_multiply #(
	parameter DATA_W = 24,
	parameter RECIP_W = 32
)(
	input logic clk,
	input logic n_rst,
	input logic in_valid,
	input logic in_div_zero,
	input logic signed [DATA_W-1:0] x_in,
	input logic signed [DATA_W-1:0] y_in,
	input logic signed [DATA_W-1:0] z_in,
	input logic signed [RECIP_W-1:0] reciprocal,
	output logic out_valid,
	output logic out_div_zero,
	output logic signed [DATA_W+RECIP_W-1:0] x_product,
	output logic signed [DATA_W+RECIP_W-1:0] y_product,
	output logic signed [DATA_W+RECIP_W-1:0] z_product
);

	logic signed [DATA_W+RECIP_W-1:0] next_x_product;
	logic signed [DATA_W+RECIP_W-1:0] next_y_product;
	logic signed [DATA_W+RECIP_W-1:0] next_z_product;
	logic next_out_valid;
	logic next_out_div_zero;

	always_comb begin : Multiply_Logic
		next_x_product = x_product;
		next_y_product = y_product;
		next_z_product = z_product;
		next_out_valid = in_valid;
		next_out_div_zero = in_div_zero;

		if (in_valid) begin
			next_x_product = $signed(x_in) * $signed(reciprocal);
			next_y_product = $signed(y_in) * $signed(reciprocal);
			next_z_product = $signed(z_in) * $signed(reciprocal);
		end
	end

	always_ff @(posedge clk or negedge n_rst) begin : Multiply_Register
		if (!n_rst) begin
			x_product <= '0;
			y_product <= '0;
			z_product <= '0;
			out_valid <= 1'b0;
			out_div_zero <= 1'b0;
		end
		else begin
			x_product <= next_x_product;
			y_product <= next_y_product;
			z_product <= next_z_product;
			out_valid <= next_out_valid;
			out_div_zero <= next_out_div_zero;
		end
	end

endmodule