module vector_delay #(
	parameter DATA_W = 24,
	parameter LATENCY = 9
)(
	input logic clk,
	input logic n_rst,

	input logic signed [DATA_W-1:0] x_in,
	input logic signed [DATA_W-1:0] y_in,
	input logic signed [DATA_W-1:0] z_in,

	output logic signed [DATA_W-1:0] x_out,
	output logic signed [DATA_W-1:0] y_out,
	output logic signed [DATA_W-1:0] z_out
);

	logic signed [DATA_W-1:0] x_pipe [0:LATENCY-1];
	logic signed [DATA_W-1:0] y_pipe [0:LATENCY-1];
	logic signed [DATA_W-1:0] z_pipe [0:LATENCY-1];

	logic signed [DATA_W-1:0] n_x_pipe [0:LATENCY-1];
	logic signed [DATA_W-1:0] n_y_pipe [0:LATENCY-1];
	logic signed [DATA_W-1:0] n_z_pipe [0:LATENCY-1];

	integer i;
	integer j;


	always_comb begin
		n_x_pipe[0] = x_in;
		n_y_pipe[0] = y_in;
		n_z_pipe[0] = z_in;

		for (i = 1; i < LATENCY; i = i + 1) begin
			n_x_pipe[i] = x_pipe[i-1];
			n_y_pipe[i] = y_pipe[i-1];
			n_z_pipe[i] = z_pipe[i-1];
		end
	end


	always_ff @(posedge clk, negedge n_rst) begin
		if (!n_rst) begin
			for (j = 0; j < LATENCY; j = j + 1) begin
				x_pipe[j] <= '0;
				y_pipe[j] <= '0;
				z_pipe[j] <= '0;
			end
		end
		else begin
			for (j = 0; j < LATENCY; j = j + 1) begin
				x_pipe[j] <= n_x_pipe[j];
				y_pipe[j] <= n_y_pipe[j];
				z_pipe[j] <= n_z_pipe[j];
			end
		end
	end


	assign x_out = x_pipe[LATENCY-1];
	assign y_out = y_pipe[LATENCY-1];
	assign z_out = z_pipe[LATENCY-1];

endmodule