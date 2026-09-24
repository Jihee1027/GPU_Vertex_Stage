module fixed_point_divider #(
	parameter DATA_W = 24,
	parameter FRAC_W = 8
)(
	input logic clk,
	input logic n_rst,
	input logic start,

	input logic signed [DATA_W-1:0] numerator,
	input logic signed [DATA_W-1:0] denominator,

	output logic signed [DATA_W-1:0] quotient,
	output logic div_zero,
	output logic busy,
	output logic done
);

	localparam EXT_W = DATA_W + FRAC_W;
	localparam COUNT_W = $clog2(EXT_W);

	localparam logic [DATA_W-1:0] MAX_POS = {1'b0, {(DATA_W-1){1'b1}}};
	localparam logic [DATA_W-1:0] MAX_NEG = {1'b1, {(DATA_W-1){1'b0}}};

	localparam logic [EXT_W-1:0] POS_LIMIT = {{FRAC_W{1'b0}}, MAX_POS};
	localparam logic [EXT_W-1:0] NEG_LIMIT = {{FRAC_W{1'b0}}, MAX_NEG};

	typedef enum logic [1:0] {
		IDLE,
		DIVIDE,
		FINALIZE,
		DONE
	} state_t;

	state_t state;
	state_t n_state;

	logic [EXT_W-1:0] dividend;
	logic [EXT_W-1:0] n_dividend;

	logic [DATA_W-1:0] divisor;
	logic [DATA_W-1:0] n_divisor;

	logic [DATA_W:0] remainder;
	logic [DATA_W:0] n_remainder;

	logic [EXT_W-1:0] quotient_work;
	logic [EXT_W-1:0] n_quotient_work;

	logic [COUNT_W-1:0] count;
	logic [COUNT_W-1:0] n_count;

	logic result_sign;
	logic n_result_sign;

	logic signed [DATA_W-1:0] n_quotient;
	logic n_div_zero;

	logic [DATA_W-1:0] numerator_mag;
	logic [DATA_W-1:0] denominator_mag;

	logic [DATA_W:0] shifted_remainder;
	logic [DATA_W:0] step_remainder;
	logic [EXT_W-1:0] step_quotient;

	logic quotient_bit;
	logic last_cycle;

	logic signed [DATA_W-1:0] final_quotient;


	// Convert signed inputs to positive magnitudes
	always_comb begin
		if (numerator[DATA_W-1]) begin
			numerator_mag = -numerator;
		end
		else begin
			numerator_mag = numerator;
		end

		if (denominator[DATA_W-1]) begin
			denominator_mag = -denominator;
		end
		else begin
			denominator_mag = denominator;
		end
	end


	// Perform one bit of division
	always_comb begin
		shifted_remainder = {remainder[DATA_W-1:0], dividend[EXT_W-1]};

		if (shifted_remainder >= {1'b0, divisor}) begin
			step_remainder = shifted_remainder - {1'b0, divisor};
			quotient_bit = 1'b1;
		end
		else begin
			step_remainder = shifted_remainder;
			quotient_bit = 1'b0;
		end

		step_quotient = {quotient_work[EXT_W-2:0], quotient_bit};
	end


	// Apply sign and saturation
	always_comb begin
		if (result_sign) begin
			if (quotient_work > NEG_LIMIT) begin
				final_quotient = MAX_NEG;
			end
			else begin
				final_quotient = -quotient_work[DATA_W-1:0];
			end
		end
		else begin
			if (quotient_work > POS_LIMIT) begin
				final_quotient = MAX_POS;
			end
			else begin
				final_quotient = quotient_work[DATA_W-1:0];
			end
		end
	end


	assign last_cycle = (count == EXT_W - 1);
	assign busy = (state == DIVIDE) || (state == FINALIZE);
	assign done = (state == DONE);


	// State machine
	always_comb begin
		n_state = state;

		case (state)
			IDLE: begin
				if (start) begin
					if (denominator == 0) begin
						n_state = DONE;
					end
					else begin
						n_state = DIVIDE;
					end
				end
			end

			DIVIDE: begin
				if (last_cycle) begin
					n_state = FINALIZE;
				end
			end

			FINALIZE: begin
				n_state = DONE;
			end

			DONE: begin
				n_state = IDLE;
			end

			default: begin
				n_state = IDLE;
			end
		endcase
	end


	// Datapath control
	always_comb begin
		n_dividend = dividend;
		n_divisor = divisor;
		n_remainder = remainder;
		n_quotient_work = quotient_work;
		n_count = count;
		n_result_sign = result_sign;
		n_quotient = quotient;
		n_div_zero = div_zero;

		case (state)
			IDLE: begin
				if (start) begin
					n_quotient = '0;
					n_div_zero = 1'b0;

					if (denominator == 0) begin
						n_div_zero = 1'b1;
					end
					else begin
						n_dividend = {numerator_mag, {FRAC_W{1'b0}}};
						n_divisor = denominator_mag;
						n_remainder = '0;
						n_quotient_work = '0;
						n_count = '0;
						n_result_sign = numerator[DATA_W-1] ^ denominator[DATA_W-1];
					end
				end
			end

			DIVIDE: begin
				n_dividend = {dividend[EXT_W-2:0], 1'b0};
				n_remainder = step_remainder;
				n_quotient_work = step_quotient;

				if (!last_cycle) begin
					n_count = count + 1'b1;
				end
			end

			FINALIZE: begin
				n_quotient = final_quotient;
			end

			DONE: begin
				n_div_zero = 1'b0;
			end

			default: begin
			end
		endcase
	end


	// Registers
	always_ff @(posedge clk, negedge n_rst) begin
		if (!n_rst) begin
			state <= IDLE;
			dividend <= '0;
			divisor <= '0;
			remainder <= '0;
			quotient_work <= '0;
			count <= '0;
			result_sign <= 1'b0;
			quotient <= '0;
			div_zero <= 1'b0;
		end
		else begin
			state <= n_state;
			dividend <= n_dividend;
			divisor <= n_divisor;
			remainder <= n_remainder;
			quotient_work <= n_quotient_work;
			count <= n_count;
			result_sign <= n_result_sign;
			quotient <= n_quotient;
			div_zero <= n_div_zero;
		end
	end

endmodule