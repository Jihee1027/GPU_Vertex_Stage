module MAT_VECM #(
    parameter SIZE = 25,
    parameter FRACBIT = 16,
    parameter INTBIT = 8
) (
    input logic clk, n_rst,
    input logic signed [SIZE -1:0] Tmatrix [0:3][0:3],
    input logic signed [SIZE - 1:0] Vinput [0:3],
    output logic signed [SIZE - 1:0] Vout [0:3]
);
    logic signed [2 * SIZE: 0] partials [0:3][0:3];
    logic signed [SIZE - 1:0] shifted_partials [0:3][0:3];
    logic signed [SIZE - 1:0] sums_l1 [0:3][0:1];
    logic signed [SIZE - 1:0] sums_l2 [0:3];
    logic signed [2 * SIZE: 0] npartials [0:3][0:3];
    logic signed [SIZE - 1:0] nshifted_partials [0:3][0:3];
    logic signed [SIZE - 1:0] nsums_l1 [0:3][0:1];
    logic signed [SIZE - 1:0] nsums_l2 [0:3];
    

    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            partials <= '{default: 0};
            shifted_partials <= '{default: 0};
            sums_l1 <= '{default: 0};
            sums_l2 <= '{default: 0};
        end else begin
            partials <= npartials;
            shifted_partials <= nshifted_partials;
            sums_l1 <= nsums_l1;
            sums_l2 <= nsums_l2;
        end
    end

    always_comb begin
        for (int i = 0; i < 4; i++) begin
            for(int j = 0; j < 4; j++) begin
                npartials[i][j] = Tmatrix[i][j] * Vinput[j];
                nshifted_partials[i][j] = partials[i][j] >> FRACBIT;
            end
            for(j = 0; j < 2; j++) begin
                nsums_l1[i][j] = shifted_partials[i][2*j] + shifted_partials[i][2*j+1];
            end
            nsums_l2[i] = sums_l1[i][0] + sums_l1[i][1];
        end

    end

    assign Vout = sums_l2;


endmodule
