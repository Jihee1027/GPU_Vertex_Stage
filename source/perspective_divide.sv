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

	localparam RECIP_LATENCY = 10;
	localparam PROD_W = DATA_W + RECIP_W;

	logic recip_valid;
	logic recip_div_zero;
	logic signed [RECIP_W-1:0] reciprocal;

	logic signed [DATA_W-1:0] x_delayed;
	logic signed [DATA_W-1:0] y_delayed;
	logic signed [DATA_W-1:0] z_delayed;

	logic mult_valid;
	logic mult_div_zero;

	logic signed [PROD_W-1:0] x_product;
	logic signed [PROD_W-1:0] y_product;
	logic signed [PROD_W-1:0] z_product;


	reciprocal_nr #(
		.DATA_W(DATA_W),
		.FRAC_W(FRAC_W),
		.RECIP_W(RECIP_W),
		.RECIP_FRAC(RECIP_FRAC)
	) recip (
		.clk(clk),
		.n_rst(n_rst),
		.in_valid(in_valid),
		.denominator(w_clip),
		.out_valid(recip_valid),
		.reciprocal(reciprocal),
		.div_zero(recip_div_zero)
	);


	vector_delay #(
		.DATA_W(DATA_W),
		.LATENCY(RECIP_LATENCY)
	) delay (
		.clk(clk),
		.n_rst(n_rst),
		.x_in(x_clip),
		.y_in(y_clip),
		.z_in(z_clip),
		.x_out(x_delayed),
		.y_out(y_delayed),
		.z_out(z_delayed)
	);


	perspective_multiply #(
		.DATA_W(DATA_W),
		.RECIP_W(RECIP_W)
	) mult (
		.clk(clk),
		.n_rst(n_rst),
		.in_valid(recip_valid),
		.in_div_zero(recip_div_zero),
		.x_in(x_delayed),
		.y_in(y_delayed),
		.z_in(z_delayed),
		.reciprocal(reciprocal),
		.out_valid(mult_valid),
		.out_div_zero(mult_div_zero),
		.x_product(x_product),
		.y_product(y_product),
		.z_product(z_product)
	);


	ndc_output #(
		.DATA_W(DATA_W),
		.RECIP_W(RECIP_W),
		.RECIP_FRAC(RECIP_FRAC)
	) output_stage (
		.clk(clk),
		.n_rst(n_rst),
		.in_valid(mult_valid),
		.in_div_zero(mult_div_zero),
		.x_product(x_product),
		.y_product(y_product),
		.z_product(z_product),
		.out_valid(out_valid),
		.div_zero(div_zero),
		.x_ndc(x_ndc),
		.y_ndc(y_ndc),
		.z_ndc(z_ndc)
	);

endmodule