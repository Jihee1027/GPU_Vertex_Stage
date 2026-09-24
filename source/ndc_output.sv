module ndc_output #(
	parameter DATA_W = 24,
	parameter RECIP_W = 32,
	parameter RECIP_FRAC = 20
)(
	input logic clk,
	input logic n_rst,

	input logic in_valid,
	input logic in_div_zero,

	input logic signed [DATA_W+RECIP_W-1:0] x_product,
	input logic signed [DATA_W+RECIP_W-1:0] y_product,
	input logic signed [DATA_W+RECIP_W-1:0] z_product,

	output logic out_valid,
	output logic div_zero,

	output logic signed [DATA_W-1:0] x_ndc,
	output logic signed [DATA_W-1:0] y_ndc,
	output logic signed [DATA_W-1:0] z_ndc
);

	localparam PROD_W = DATA_W + RECIP_W;

	localparam logic signed [DATA_W-1:0] MAX_POS = {1'b0, {(DATA_W-1){1'b1}}};
	localparam logic signed [DATA_W-1:0] MIN_NEG = {1'b1, {(DATA_W-1){1'b0}}};

	localparam logic signed [PROD_W-1:0] MAX_EXT = {{(PROD_W-DATA_W){1'b0}}, MAX_POS};
	localparam logic signed [PROD_W-1:0] MIN_EXT = {{(PROD_W-DATA_W){1'b1}}, MIN_NEG};

	logic signed [DATA_W-1:0] n_x_ndc;
	logic signed [DATA_W-1:0] n_y_ndc;
	logic signed [DATA_W-1:0] n_z_ndc;

	logic n_out_valid;
	logic n_div_zero;


	function automatic logic signed [DATA_W-1:0] scale_and_saturate(
		input logic signed [PROD_W-1:0] product
	);

		logic signed [PROD_W-1:0] shifted;

		begin
			shifted = product >>> RECIP_FRAC;

			if (shifted > MAX_EXT) begin
				scale_and_saturate = MAX_POS;
			end
			else if (shifted < MIN_EXT) begin
				scale_and_saturate = MIN_NEG;
			end
			else begin
				scale_and_saturate = shifted[DATA_W-1:0];
			end
		end

	endfunction


	always_comb begin
		n_x_ndc = x_ndc;
		n_y_ndc = y_ndc;
		n_z_ndc = z_ndc;

		n_out_valid = in_valid;
		n_div_zero = 1'b0;

		if (in_valid) begin
			n_div_zero = in_div_zero;

			if (in_div_zero) begin
				n_x_ndc = '0;
				n_y_ndc = '0;
				n_z_ndc = '0;
			end
			else begin
				n_x_ndc = scale_and_saturate(x_product);
				n_y_ndc = scale_and_saturate(y_product);
				n_z_ndc = scale_and_saturate(z_product);
			end
		end
	end


	always_ff @(posedge clk, negedge n_rst) begin
		if (!n_rst) begin
			x_ndc <= '0;
			y_ndc <= '0;
			z_ndc <= '0;

			out_valid <= 1'b0;
			div_zero <= 1'b0;
		end
		else begin
			x_ndc <= n_x_ndc;
			y_ndc <= n_y_ndc;
			z_ndc <= n_z_ndc;

			out_valid <= n_out_valid;
			div_zero <= n_div_zero;
		end
	end

endmodule