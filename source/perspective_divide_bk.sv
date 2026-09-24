module perspective_divide_bk #(
	parameter DATA_W = 24,
	parameter FRAC_W = 8
)(
	input logic clk,
	input logic n_rst,
	input logic start,

	input logic signed [DATA_W-1:0] x_clip,
	input logic signed [DATA_W-1:0] y_clip,
	input logic signed [DATA_W-1:0] z_clip,
	input logic signed [DATA_W-1:0] w_clip,

	output logic signed [DATA_W-1:0] x_ndc,
	output logic signed [DATA_W-1:0] y_ndc,
	output logic signed [DATA_W-1:0] z_ndc,

	output logic div_zero,
	output logic busy,
	output logic done
);

	logic signed [DATA_W-1:0] x_divided;
	logic signed [DATA_W-1:0] y_divided;
	logic signed [DATA_W-1:0] z_divided;

	logic x_div_zero, y_div_zero, z_div_zero;
	logic x_busy, y_busy, z_busy;
	logic x_done, y_done, z_done;


	fixed_point_divider #(
		.DATA_W(DATA_W),
		.FRAC_W(FRAC_W)
	) x_div (
		.clk(clk),
		.n_rst(n_rst),
		.start(start),
		.numerator(x_clip),
		.denominator(w_clip),
		.quotient(x_divided),
		.div_zero(x_div_zero),
		.busy(x_busy),
		.done(x_done)
	);


	fixed_point_divider #(
		.DATA_W(DATA_W),
		.FRAC_W(FRAC_W)
	) y_div (
		.clk(clk),
		.n_rst(n_rst),
		.start(start),
		.numerator(y_clip),
		.denominator(w_clip),
		.quotient(y_divided),
		.div_zero(y_div_zero),
		.busy(y_busy),
		.done(y_done)
	);


	fixed_point_divider #(
		.DATA_W(DATA_W),
		.FRAC_W(FRAC_W)
	) z_div (
		.clk(clk),
		.n_rst(n_rst),
		.start(start),
		.numerator(z_clip),
		.denominator(w_clip),
		.quotient(z_divided),
		.div_zero(z_div_zero),
		.busy(z_busy),
		.done(z_done)
	);


	// Divider outputs are already registered
	assign x_ndc = x_divided;
	assign y_ndc = y_divided;
	assign z_ndc = z_divided;

	// Perspective divide status
	assign div_zero = x_div_zero | y_div_zero | z_div_zero;
	assign busy = x_busy | y_busy | z_busy;
	assign done = x_done & y_done & z_done;

endmodule