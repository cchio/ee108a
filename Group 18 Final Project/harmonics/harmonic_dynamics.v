// states
`define OFF 2'd0
`define ATTACK 2'd1
`define HOLD 2'd2
`define RELEASE 2'd3

// gain range
`define MIN_GAIN 8'd0
`define MAX_GAIN 8'd128


module harmonic_dynamics
    #(parameter ATTACK_TIME = 75,
    parameter SUSTAIN_TIME = 1400,
    parameter REL_TIME = 1400)
(
    input clk,
    input reset,
    input load_new_note,
    input done,
    input generate_next,
    input sample_ready,
    input signed [15:0] sample_in,

    output [7:0] gain,
    output decay_type //0 for linear, 1 for exponential
);

    reg [1:0] next_state;
    wire [1:0] curr_state;
    reg [15:0] count1;
    wire [15:0] count;
    reg [7:0] gain1;
    wire zero_crossing;
    reg signed [15:0] prev_sample1;
    wire signed [15:0] prev_sample;

    // Wire assigns
    assign decay_type = (curr_state != `ATTACK);
    assign zero_crossing = (prev_sample[15] != sample_in[15]);


    // flip flop instantiations

    dffr #(.WIDTH(2)) fsm_state (
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(curr_state)
    );

    dffr #(.WIDTH(16)) sample_counter (
        .clk(clk),
        .r(reset),
        .d(count1),
        .q(count)
    );

    dffr #(.WIDTH(16)) prev_sample_ff (
        .clk(clk),
        .r(reset),
        .d(prev_sample1),
        .q(prev_sample)
    );

    dffr #(.WIDTH(8)) gain_ff (
        .clk(clk),
        .r(reset),
        .d(gain1),
        .q(gain)
    );


    // this block handles proper state transitions for note output
    always @(*) begin
        if (reset) begin
            next_state = `OFF;
            count1 = 16'b0;
            gain1 = 8'b0;
        end
        else if (curr_state == `OFF) begin
            count1 = 16'b0;
            gain1 = 8'b0;

            if (load_new_note)
                next_state = `ATTACK;
            else next_state = curr_state;
        end
        else if (curr_state == `ATTACK) begin
            if (generate_next) begin
		count1 = count + 16'b1;
		gain1 = gain;
		next_state = curr_state;
	    end
            else if ((count >= ATTACK_TIME) & zero_crossing) begin
                count1 = 16'b0;
                if (gain == `MAX_GAIN) begin
			next_state = `HOLD;
			gain1 = gain;
		end
                else begin
			gain1 = gain + 8'b1;
			next_state = curr_state;
		end
            end
            else begin
                next_state = curr_state;
                count1 = count;
                gain1 = gain;
            end
        end
        else if (curr_state == `HOLD) begin
            if (done) begin
                count1 = 16'b0;
                next_state = `RELEASE;
		gain1 = gain;
            end
            else if (generate_next) begin
		count1 = count + 16'b1;
		next_state = curr_state;
		gain1 = gain;
	    end
            else if ((count >= SUSTAIN_TIME) & zero_crossing) begin
                count1 = 16'b0;
		next_state = curr_state;
                if (gain == `MIN_GAIN) gain1 = gain;
                else gain1 = gain - 8'b1;
            end
            else begin
                next_state = curr_state;
                count1 = count;
                gain1 = gain;
            end
        end
        else begin
		next_state = `OFF;
		count1 = count;
		gain1 = gain;
	end
    end


    // This block updates the previous sample
    always @(*) begin
        if (reset) prev_sample1 = 16'sb0;
        else if (generate_next) prev_sample1 = sample_in;
        else prev_sample1 = prev_sample;
    end

endmodule