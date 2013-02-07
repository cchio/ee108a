// states
`define OFF 2'd0
`define ATTACK 2'd1
`define HOLD 2'd2
`define RELEASE 2'd3

// timing values
`define DELAY 4'd5
`define ATTACK_INTERVAL 16'd
`define SUSTAIN_INTERVAL 16'd5650
`define REL_INTERVAL 16'd187

// note range
`define NOTE_MIN 7'd29
`define NOTE_MAX 7'd91

// sustain pedal minimum value
`define SUS_MIN 8'd64

module midi_sin_voice (
    input clk,
    input reset,
    input update_voice,
    input update_all_voices,
    input [15:0] controller_values,
    input [15:0] note_values,
    input generate_next,
    input sample_ready,
    input [15:0] sample_in,

    output reg voice_on,
    output [5:0] note,
    output sample_out_ready,
    output [15:0] sample_out
);

    reg [1:0] next_state;
    wire [1:0] curr_state;
    reg [15:0] count1;
    wire [15:0] count;
    reg [3:0] clk_count1;
    wire [3:0] clk_count;
    reg [7:0] sustain_controller1;
    wire [7:0] sustain_controller;
    reg [7:0] vel1;
    wire [7:0] vel;
    reg [3:0] gain;
    wire [7:0] lin_gain1, lin_gain, expo_gain1, expo_gain;
    wire zero_crossing;
    reg [15:0] sample_reg1, prev_sample1;
    wire [15:0] sample_in_ff1, sample_in_ff, sample_reg, prev_sample;

    // Wire assigns
    assign sample_in_ff1 = sample_in;
    assign sample_reg1 = (curr_state == `ATTACK)
      ? sample_in_ff-(lin_gain*(sample_in_ff>>7))
      : sample_in_ff-(expo_gain*(sample_in_ff>>7));
    assign sample_out = (vel < 8'd64)
      ? (vel < 8'd96) ? sample_reg-sample_reg>>2 : sample_reg
      : (vel < 8'd32) ? sample_reg>>2 : sample_reg>>1;
    assign zero_crossing = (prev_sample[15] != sample_in_ff[15]);
    assign note = ((note_values[6:0] >= `NOTE_MIN) &
      (note_values[6:0] <= `NOTE_MAX))
      ? (note_values[6:0]-`NOTE_MIN+7'b1)[5:0]
      : 6'b0;

    // ROM/FF instantiations

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

    dffr #(.WIDTH(4)) clk_counter (
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

    dffr #(.WIDTH(16)) sample_ff (
        .clk(clk),
        .r(reset),
        .d(sample_in_ff1),
        .q(sample_in_ff)
    );

    dffr #(.WIDTH(16)) sample_reg_ff (
        .clk(clk),
        .r(reset),
        .d(sample_reg1),
        .q(sample_reg)
    );

    dffr #(.WIDTH(8)) sustain (
        .clk(clk),
        .r(reset),
        .d(sustain_controller1),
        .q(sustain_controller)
    );

    dffr #(.WIDTH(8)) velocity (
        .clk(clk),
        .r(reset),
        .d(vel1),
        .q(vel)
    );

    dffr #.WIDTH(8)) lin_ff (
        .clk(clk),
        .r(reset),
        .d(lin_gain1),
        .q(lin_gain)
    );

    dffr #(.WIDTH(7)) expo_ff (
        .clk(clk),
        .r(reset),
        .d(expo_gain1),
        .q(expo_gain)
    );


    linear_scale_rom lin_rom (
        .clk(clk),
        .addr(gain),
        .dout(lin_gain1)
    );

    exponential_scale_rom expo_rom (
        .clk(clk),
        .addr(gain),
        .dout(expo_gain1)
    );


    // this block handles proper state transitions for note output
    always @(*) begin
        if (reset) begin
            next_state = `OFF;
            count1 = 16'b0;
            clk_count1 = 4'b0;
            voice_on = 1'b0;
            gain = 4'b0;
            prev_sample1 = 16'b0;
        end
        else if (curr_state == `OFF) begin
            count1 = 16'b0;
            prev_sample1 = 16'b0;
            gain = 4'b0;

            if (update_voice & (note_values[15:8] != 8'b0)) begin
                voice_on = 1'b1;
                next_state = `ATTACK;
                vel1 = note_values[15:8];
            end
            else if (sample_ready) clk_count1 = 4'b1;
            else if ((clk_count != 4'b0) & (clk_count != `DELAY))
                clk_count1 = clk_count + 4'b1;
            else if (clk_count == `DELAY) begin
                sample_out_ready = 1'b1;
                clk_count1 = 4'b0;
            end
            else begin
                next_state = curr_state;
                voice_on = 1'b0;
                sample_out_ready = 1'b0;
            end
        end
        else if (curr_state == `ATTACK) begin
            if (generate_next) count1 = count + 16'b1;
            else if ((count >= `ATTACK_INTERVAL) & zero_crossing) begin
                count1 = 16'b0;
                if (gain == ~4'b0) next_state = `HOLD;
                else gain = gain + 4'b1;
            end
            else if (sample_ready) clk_count1 = 4'b1;
            else if ((clk_count != 4'b0) & (clk_count != `DELAY))
                clk_count1 = clk_count + 4'b1;
            else if (clk_count == `DELAY) begin
                sample_out_ready = 1'b1;
                clk_count1 = 4'b0;
            end
            else begin
                next_state = curr_state;
                sample_out_ready = 1'b0;
                prev_sample1 = sample_in_ff;
            end
        end
        else if (curr_state == `HOLD) begin
            if (update_note & (note_values[15:8] == 8'b0)) begin
                count1 = 16'b0;
                clk_count1 = 4'b0;
                next_state = `RELEASE;
            end
            else if (generate_next) count1 = count + 16'b1;
            else if ((count == `SUSTAIN_INTERVAL) & zero_crossing) begin
                count1 = 16'b0;
                if (gain == 4'b0) gain = 4'b0;
                else gain = gain - 4'b1;
            end
            else if (sample_ready) clk_count1 = 4'b1;
            else if ((clk_count != 4'b0) & (clk_count != `DELAY))
                clk_count1 = clk_count + 4'b1;
            else if (clk_count == `DELAY) begin
                sample_out_ready = 1'b1;
                clk_count1 = 4'b0;
            end
            else begin
                next_state = curr_state;
                sample_out_ready = 1'b0;
                prev_sample1 = sample_in_ff;
            end
        end
        else begin
            if (generate_next) count1 = count + 16'b1;
            else if (((sustain_controller >= `SUS_MIN)
              & (count == `SUSTAIN_INTERVAL))
              | ((sustain_controller < `SUS_MIN)
              & (count == `REL_INTERVAL))
              & zero_crossing) begin
                count1 = 16'b0;
                if (gain == 4'b0) next_state = `OFF;
                else gain = gain - 4'b1;
            end
            else if (sample_ready) clk_count1 = 4'b1;
            else if ((clk_count != 4'b0) & (clk_count != `DELAY))
                clk_count1 = clk_count + 4'b1;
            else if (clk_count == `DELAY) begin
                sample_out_ready = 1'b1;
                clk_count1 = 4'b0;
            end
            else begin
                next_state = curr_state;
                sample_out_ready = 1'b0;
                prev_sample1 = sample_in_ff;
            end
        end
    end

    // this block handles updating the controller values
    always @(*) begin
        if (reset) sustain_controller1 = 8'b0;
        else if (update_all_voices) begin
            case (controller_voices[7:0])
              8'd64: sustain_controller1 = controller_values[15:8];
              default: sustain_controller1 = sustain_controller;
            endcase
        end
        else sustain_controller1 = sustain_controller;
    end

endmodule
