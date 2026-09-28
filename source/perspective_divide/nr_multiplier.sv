// Pipeline multiplier for reciprocal

module nr_multiplier #(
	parameter A_W = 24,
	parameter B_W = 24
)(
	input logic clk,
	input logic n_rst,
	input logic [A_W-1:0] a,
	input logic [B_W-1:0] b,
	output logic [(A_W+B_W)-1:0] product
);

	localparam LOW_W = 18;
	localparam HIGH_W = B_W - LOW_W;
	localparam PRODUCT_W = A_W + B_W;

	logic [A_W+LOW_W-1:0] low_product;
	logic [A_W+HIGH_W-1:0] high_product;

	logic [PRODUCT_W-1:0] low_full;
	logic [PRODUCT_W-1:0] high_full;


	always_comb begin : Add_Products_Logic
		low_full = {{HIGH_W{1'b0}}, low_product};
		high_full = {high_product, {LOW_W{1'b0}}};
	end


	always_ff @(posedge clk or negedge n_rst) begin : Multiplier_Pipeline
		if (!n_rst) begin
			low_product <= '0;
			high_product <= '0;
			product <= '0;
		end
		else begin
			low_product <= a * b[LOW_W-1:0];
			high_product <= a * b[B_W-1:LOW_W];
			product <= low_full + high_full;
		end
	end

endmodule