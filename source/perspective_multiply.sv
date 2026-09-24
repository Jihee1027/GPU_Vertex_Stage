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

	localparam PROD_W = DATA_W + RECIP_W;

	logic signed [PROD_W-1:0] n_x_product;
	logic signed [PROD_W-1:0] n_y_product;
	logic signed [PROD_W-1:0] n_z_product;

	logic n_out_valid;
	logic n_out_div_zero;


	always_comb begin
		n_x_product = x_product;
		n_y_product = y_product;
		n_z_product = z_product;

		n_out_valid = in_valid;
		n_out_div_zero = in_div_zero;

		if (in_valid) begin
			n_x_product = $signed(x_in) * $signed(reciprocal);
			n_y_product = $signed(y_in) * $signed(reciprocal);
			n_z_product = $signed(z_in) * $signed(reciprocal);
		end
	end


	always_ff @(posedge clk, negedge n_rst) begin
		if (!n_rst) begin
			x_product <= '0;
			y_product <= '0;
			z_product <= '0;

			out_valid <= 1'b0;
			out_div_zero <= 1'b0;
		end
		else begin
			x_product <= n_x_product;
			y_product <= n_y_product;
			z_product <= n_z_product;

			out_valid <= n_out_valid;
			out_div_zero <= n_out_div_zero;
		end
	end

endmodule