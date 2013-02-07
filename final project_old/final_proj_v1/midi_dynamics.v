// states
`define OFF 2'd0
`define ATTACK 2'd1
`define HOLD 2'd2
`define RELEASE 2'd3

// timing values
`define DELAY 6'd32

// note range
`define NOTE_MIN 7'd29
`define NOTE_MAX 7'd91

// sustain pedal minimum value
`define SUS_MIN 8'd64

// gain range
`define MIN_GAIN 8'd0
`define MAX_GAIN 8'd128


module midi_dynamics
    #(parameter ATTACK_TIME = 75,
    parameter SUSTAIN_TIME = 1400,
    parameter REL_TIME = 150)
(
    input clk,
    input reset,
    input update_voice,
    input update_all_voices,
    input [15:0] controller_values,
    input [15:0] note_values,
    input generate_next,
    input sample_ready,
    input signed [15:0] sample_in,

    output reg voice_on,
    output [5:0] note,
    output reg sample_out_ready,
    output signed [15:0] sample_out
);

    reg [1:0] next_state;
    wire [1:0] curr_state;
    reg [15:0] count1;
    wire [15:0] count;
    reg [5:0] clk_count1;
    wire [5:0] clk_count;
    reg [7:0] sustain_controller1;
    wire [7:0] sustain_controller;
    reg [7:0] velocity1;
    wire [7:0] velocity;
    reg [7:0] gain1;
    wire [7:0] gain;
    wire zero_crossing;
    reg signed [15:0] prev_sample1;
    wire signed [15:0] prev_sample;
    reg [6:0] temp_note;
    wire signed [15:0] result1, result2, result3, result4;
    wire [15:0] sustain_inc, sustain;

    // Wire assigns
    assign sustain = SUSTAIN_TIME + sustain_inc;
    assign zero_crossing = (prev_sample[15] != sample_in[15]);
    assign note = ((note_values[6:0] >= `NOTE_MIN) &
      (note_values[6:0] <= `NOTE_MAX))
      ? temp_note[5:0] : 6'b0;

    // Pipelined scaler instantiations
    // A sequence of 5 scalers is used to allow for exponential decay and velocity
    // sensitivity

    pipelined_scaler1_128 scaler1 (
        .clk(clk),
        .reset(reset),
        .in(sample_in),
        .multiplier(gain),
        .out(result1)
    );

    pipelined_scaler1_128 scaler2 (
        .clk(clk),
        .reset(reset),
        .in(result1),
        .multiplier((curr_state == `ATTACK) ? `MAX_GAIN : gain),
        .out(result2)
    );

    pipelined_scaler1_128 scaler3 (
        .clk(clk),
        .reset(reset),
        .in(result2),
        .multiplier((curr_state == `ATTACK) ? `MAX_GAIN : gain),
        .out(result3)
    );

    pipelined_scaler1_128 scaler4 (
        .clk(clk),
        .reset(reset),
        .in(result3),
        .multiplier((curr_state == `ATTACK) ? `MAX_GAIN : gain),
        .out(result4)
    );

    pipelined_scaler1_128 vel_scaler (
        .clk(clk),
        .reset(reset),
        .in(result4),
        .multiplier(velocity+8'd1),
        .out(sample_out)
    );



    // module to calculate the sustain length variation for different notes

    sustain_variation sust_var (
        .clk(clk),
        .reset(reset),
        .note(note),
        .count(sustain_inc)
    );


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

    dffr #(.WIDTH(6)) clk_counter (
        .clk(clk),
        .r(reset),
        .d(clk_count1),
        .q(clk_count)
    );

    dffr #(.WIDTH(16)) prev_sample_ff (
        .clk(clk),
        .r(reset),
        .d(prev_sample1),
        .q(prev_sample)
    );

    dffr #(.WIDTH(8)) sustain_ff (
        .clk(clk),
        .r(reset),
        .d(sustain_controller1),
        .q(sustain_controller)
    );

    dffr #(.WIDTH(8)) velocity_ff (
        .clk(clk),
        .r(reset),
        .d(velocity1),
        .q(velocity)
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
            clk_count1 = 6'b0;
            voice_on = 1'b0;
            gain1 = 8'b0;
            temp_note = 7'b0;
        end
        else if (curr_state == `OFF) begin
            count1 = 16'b0;
            gain1 = 8'b0;

            if (update_voice & (note_values[15:8] != 8'b0)) begin
                voice_on = 1'b1;
                next_state = `ATTACK;
                velocity1 = note_values[15:8];
                temp_note = (note_values[6:0]-`NOTE_MIN+7'b1);
            end
            else if (sample_ready) clk_count1 = 6'b1;
            else if ((clk_count != 6'b0) & (clk_count != `DELAY))
                clk_count1 = clk_count + 6'b1;
            else if (clk_count == `DELAY) begin
                sample_out_ready = 1'b1;
                clk_count1 = 6'b0;
            end
            else begin
                next_state = curr_state;
                voice_on = 1'b0;
                sample_out_ready = 1'b0;
                velocity1 = velocity;
                temp_note = 7'b0;
            end
        end
        else if (curr_state == `ATTACK) begin
            if (generate_next) count1 = count + 16'b1;
            else if ((count >= ATTACK_TIME) & zero_crossing) begin
                count1 = 16'b0;
                if (gain == `MAX_GAIN) next_state = `HOLD;
                else gain1 = gain + 8'b1;
            end
            else if (sample_ready) clk_count1 = 6'b1;
            else if ((clk_count != 6'b0) & (clk_count != `DELAY))
                clk_count1 = clk_count + 6'b1;
            else if (clk_count == `DELAY) begin
                sample_out_ready = 1'b1;
                clk_count1 = 6'b0;
            end
            else begin
                next_state = curr_state;
                sample_out_ready = 1'b0;
                count1 = count;
                gain1 = gain;
                velocity1 = velocity;
            end
        end
        else if (curr_state == `HOLD) begin
            if (update_voice & (note_values[15:8] == 8'b0)) begin
                count1 = 16'b0;
                clk_count1 = 6'b0;
                next_state = `RELEASE;
            end
            else if (generate_next) count1 = count + 16'b1;
            else if ((count >= sustain) & zero_crossing) begin
                count1 = 16'b0;
                if (gain == `MIN_GAIN) gain1 = gain;
                else gain1 = gain - 8'b1;
            end
            else if (sample_ready) clk_count1 = 6'b1;
            else if ((clk_count != 6'b0) & (clk_count != `DELAY))
                clk_count1 = clk_count + 6'b1;
            else if (clk_count == `DELAY) begin
                sample_out_ready = 1'b1;
                clk_count1 = 6'b0;
            end
            else begin
                next_state = curr_state;
                sample_out_ready = 1'b0;
                count1 = count;
                gain1 = gain;
                velocity1 = velocity;
            end
        end
        else begin
            if (gain == `MIN_GAIN) next_state = `OFF;
            else if (generate_next) count1 = count + 16'b1;
            else if (((sustain_controller >= `SUS_MIN)
              & (count >= sustain))
              | ((sustain_controller < `SUS_MIN)
              & (count >= REL_TIME))
              & zero_crossing) begin
                count1 = 16'b0;
                if (gain != `MIN_GAIN) gain1 = gain - 8'b1;
                else gain1 = gain;
            end
            else if (sample_ready) clk_count1 = 6'b1;
            else if ((clk_count != 6'b0) & (clk_count != `DELAY))
                clk_count1 = clk_count + 6'b1;
            else if (clk_count == `DELAY) begin
                sample_out_ready = 1'b1;
                clk_count1 = 6'b0;
            end
            else begin
                next_state = curr_state;
                sample_out_ready = 1'b0;
                count1 = count;
                gain1 = gain;
                velocity1 = velocity;
            end
        end
    end

    // this block handles updating the controller values
    always @(*) begin
        if (reset) sustain_controller1 = 8'b0;
        else if (update_all_voices) begin
            case (controller_values[7:0])
              8'd64: sustain_controller1 = controller_values[15:8];
              default: sustain_controller1 = sustain_controller;
            endcase
        end
        else sustain_controller1 = sustain_controller;
    end


    // This block updates the previous sample
    always @(*) begin
        if (reset) prev_sample1 = 16'sb0;
        else if (sample_out_ready) prev_sample1 = sample_in;
        else prev_sample1 = prev_sample;
    end

endmodule
