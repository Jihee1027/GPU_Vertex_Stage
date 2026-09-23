module row_mac #(
	parameter DATA_W = 24,
	parameter FRAC_W = 8,
	parameter ACC_W = 50
)(
	input logic signed [DATA_W-1:0] x,
	input logic signed [DATA_W-1:0] y,
	input logic signed [DATA_W-1:0] z,
	input logic signed [DATA_W-1:0] w,

	input logic signed [DATA_W-1:0] m0,
	input logic signed [DATA_W-1:0] m1,
	input logic signed [DATA_W-1:0] m2,
	input logic signed [DATA_W-1:0] m3,

	output logic signed [DATA_W-1:0] result
);

	logic signed [(DATA_W*2)-1:0] p0, p1, p2, p3;
	logic signed [ACC_W-1:0] p0_ext, p1_ext, p2_ext, p3_ext;
	logic signed [ACC_W-1:0] sum;
	logic signed [ACC_W-1:0] scaled;

	localparam signed [ACC_W-1:0] MAX_VAL = (2**(DATA_W - 1)) - 1;
	localparam signed [ACC_W-1:0] MIN_VAL = -(2**(DATA_W - 1));

	assign p0 = x * m0;
	assign p1 = y * m1;
	assign p2 = z * m2;
	assign p3 = w * m3;

	assign p0_ext = {{(ACC_W-(DATA_W*2)){p0[(DATA_W*2)-1]}}, p0};
	assign p1_ext = {{(ACC_W-(DATA_W*2)){p1[(DATA_W*2)-1]}}, p1};
	assign p2_ext = {{(ACC_W-(DATA_W*2)){p2[(DATA_W*2)-1]}}, p2};
	assign p3_ext = {{(ACC_W-(DATA_W*2)){p3[(DATA_W*2)-1]}}, p3};

	assign sum = p0_ext + p1_ext + p2_ext + p3_ext;
	assign scaled = sum >>> FRAC_W;

	always_comb begin
		if (scaled > MAX_VAL)
			result = MAX_VAL[DATA_W-1:0];
		else if (scaled < MIN_VAL)
			result = MIN_VAL[DATA_W-1:0];
		else
			result = scaled[DATA_W-1:0];
	end

endmodule