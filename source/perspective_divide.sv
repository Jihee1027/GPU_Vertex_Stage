`include "perspective_divide/nr_multiplier.sv"
`include "perspective_divide/nr_iteration.sv"
`include "perspective_divide/reciprocal_nr.sv"
`include "perspective_divide/vector_delay.sv"
`include "perspective_divide/perspective_multiply.sv"

module perspective_divide #(
	parameter DATA_W = 24,
	parameter FRAC_W = 8,
	parameter RECIP_W = 32,
	parameter RECIP_FRAC = 20
)(
	input logic clk,
	input logic n_rst,
	input logic in_valid,
	input logic signed [DATA_W-1:0] x_clip,
	input logic signed [DATA_W-1:0] y_clip,
	input logic signed [DATA_W-1:0] z_clip,
	input logic signed [DATA_W-1:0] w_clip,
	output logic out_valid,
	output logic signed [DATA_W-1:0] x_ndc,
	output logic signed [DATA_W-1:0] y_ndc,
	output logic signed [DATA_W-1:0] z_ndc,
	output logic div_zero
);

	localparam RECIP_LATENCY = 11;
	localparam PRODUCT_W = DATA_W + RECIP_W;
	localparam logic signed [PRODUCT_W-1:0] MAX_VALUE = {{(PRODUCT_W-DATA_W){1'b0}}, 1'b0, {(DATA_W-1){1'b1}}};
	localparam logic signed [PRODUCT_W-1:0] MIN_VALUE = {{(PRODUCT_W-DATA_W){1'b1}}, 1'b1, {(DATA_W-1){1'b0}}};
	logic recip_valid;
	logic recip_zero;
	logic signed [RECIP_W-1:0] reciprocal;
	logic signed [DATA_W-1:0] x_delayed;
	logic signed [DATA_W-1:0] y_delayed;
	logic signed [DATA_W-1:0] z_delayed;
	logic mult_valid;
	logic mult_zero;
	logic signed [PRODUCT_W-1:0] x_product;
	logic signed [PRODUCT_W-1:0] y_product;
	logic signed [PRODUCT_W-1:0] z_product;
	logic signed [PRODUCT_W-1:0] x_scaled;
	logic signed [PRODUCT_W-1:0] y_scaled;
	logic signed [PRODUCT_W-1:0] z_scaled;
	logic signed [DATA_W-1:0] next_x_ndc;
	logic signed [DATA_W-1:0] next_y_ndc;
	logic signed [DATA_W-1:0] next_z_ndc;
	logic next_out_valid;
	logic next_div_zero;

	// Calculate 1 / w
	reciprocal_nr #(
		.DATA_W(DATA_W),
		.FRAC_W(FRAC_W),
		.RECIP_W(RECIP_W),
		.RECIP_FRAC(RECIP_FRAC)
	) RECIPROCAL (
		.clk(clk),
		.n_rst(n_rst),
		.in_valid(in_valid),
		.denominator(w_clip),
		.out_valid(recip_valid),
		.reciprocal(reciprocal),
		.div_zero(recip_zero)
	);

	// Delay x, y, z
	vector_delay #(
		.DATA_W(DATA_W),
		.LATENCY(RECIP_LATENCY)
	) VECTOR_DELAY (
		.clk(clk),
		.n_rst(n_rst),
		.x_in(x_clip),
		.y_in(y_clip),
		.z_in(z_clip),
		.x_out(x_delayed),
		.y_out(y_delayed),
		.z_out(z_delayed)
	);

	// Multiply x, y, z by 1 / w
	perspective_multiply #(
		.DATA_W(DATA_W),
		.RECIP_W(RECIP_W)
	) MULTIPLY (
		.clk(clk),
		.n_rst(n_rst),
		.in_valid(recip_valid),
		.in_div_zero(recip_zero),
		.x_in(x_delayed),
		.y_in(y_delayed),
		.z_in(z_delayed),
		.reciprocal(reciprocal),
		.out_valid(mult_valid),
		.out_div_zero(mult_zero),
		.x_product(x_product),
		.y_product(y_product),
		.z_product(z_product)
	);

	// Convert product back to 24-bit
	always_comb begin : Output_Logic
		x_scaled = x_product >>> RECIP_FRAC;
		y_scaled = y_product >>> RECIP_FRAC;
		z_scaled = z_product >>> RECIP_FRAC;
		next_x_ndc = x_scaled[DATA_W-1:0];
		next_y_ndc = y_scaled[DATA_W-1:0];
		next_z_ndc = z_scaled[DATA_W-1:0];

		if (x_scaled > MAX_VALUE) begin
			next_x_ndc = MAX_VALUE[DATA_W-1:0];
		end else if (x_scaled < MIN_VALUE) begin
			next_x_ndc = MIN_VALUE[DATA_W-1:0];
		end
		if (y_scaled > MAX_VALUE) begin
			next_y_ndc = MAX_VALUE[DATA_W-1:0];
		end else if (y_scaled < MIN_VALUE) begin
			next_y_ndc = MIN_VALUE[DATA_W-1:0];
		end
		if (z_scaled > MAX_VALUE) begin
			next_z_ndc = MAX_VALUE[DATA_W-1:0];
		end else if (z_scaled < MIN_VALUE) begin
			next_z_ndc = MIN_VALUE[DATA_W-1:0];
		end
		if (mult_zero) begin
			next_x_ndc = '0;
			next_y_ndc = '0;
			next_z_ndc = '0;
		end
		next_out_valid = mult_valid;
		next_div_zero = mult_zero;
	end

	always_ff @(posedge clk or negedge n_rst) begin : Output_Register
		if (!n_rst) begin
			x_ndc <= '0;
			y_ndc <= '0;
			z_ndc <= '0;
			out_valid <= 1'b0;
			div_zero <= 1'b0;
		end else begin
			x_ndc <= next_x_ndc;
			y_ndc <= next_y_ndc;
			z_ndc <= next_z_ndc;
			out_valid <= next_out_valid;
			div_zero <= next_div_zero;
		end
	end
endmodule