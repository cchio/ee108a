// states
`define OFF 2'd0
`define ATTACK 2'd1
`define HOLD 2'd2
`define RELEASE 2'd3

// note range
`define NOTE_MIN 7'd29
`define NOTE_MAX 7'd91

// sustain pedal minimum value
`define SUS_MIN 8'd64

// gain range
`define MIN_GAIN 8'd0
`define MAX_GAIN 8'd128


module midi_harmonic_dynamics
    #(parameter ATTACK_TIME = 75,
    parameter SUSTAIN_TIME = 1400,
    parameter REL_TIME = 150)
(
    input clk,
    input reset,
    input update_voice,
    input update_all_voices,
    input [13:0] controller_values,
    input [13:0] note_values,
    input generate_next,
    input [15:0] sustain_inc,
    input sample_ready,
    input signed [15:0] sample_in,

    output voice_on,
    output [5:0] note,
    output [7:0] velocity,
    output [7:0] gain,
    output decay_type
);

    reg [1:0] next_state;
    wire [1:0] curr_state;
    reg [15:0] count1;
    wire [15:0] count;
    reg [7:0] sustain_controller1;
    wire [7:0] sustain_controller;
    reg [7:0] velocity1;
    reg [7:0] gain1;
    wire zero_crossing;
    reg signed [15:0] prev_sample1;
    wire signed [15:0] prev_sample;
    reg [6:0] temp_note1;
    wire [6:0] temp_note;
    wire [15:0] sustain;

    // Wire assigns
    assign voice_on = (curr_state != `OFF);
    assign decay_type = (curr_state != `ATTACK);
    assign sustain = SUSTAIN_TIME + sustain_inc;
    assign zero_crossing = (prev_sample[15] != sample_in[15]);
    assign note = ((note_values[6:0] >= `NOTE_MIN) &
      (note_values[6:0] <= `NOTE_MAX))
      ? temp_note[5:0] : 6'b0;


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

    dffr #(.WIDTH(7)) temp_note_ff (
        .clk(clk),
        .r(reset),
        .d(temp_note1),
        .q(temp_note)
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
            gain1 = 8'b0;
            temp_note1 = 7'b0;
	    velocity1 = velocity;
        end
        else if (curr_state == `OFF) begin
            count1 = 16'b0;
            gain1 = 8'b0;

            if (update_voice & (note_values[15:8] != 8'b0)) begin
                next_state = `ATTACK;
                velocity1 = {1'b0, note_values[13:7]};
                temp_note1 = (note_values[6:0]-`NOTE_MIN+7'b1);
            end
            else begin
                next_state = curr_state;
                velocity1 = 8'b0;
                temp_note1 = 7'b0;
            end
        end
        else if (curr_state == `ATTACK) begin
            temp_note1 = temp_note;
            if (generate_next) begin
                count1 = count + 16'b1;
                gain1 = gain;
		velocity1 = velocity;
		next_state = curr_state;
            end
            else if ((count >= ATTACK_TIME) & zero_crossing) begin
                count1 = 16'b0;
		velocity1 = velocity;
                if (gain == `MAX_GAIN) begin
			gain1 = gain;
			next_state = `HOLD;
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
                velocity1 = velocity;
            end
        end
        else if (curr_state == `HOLD) begin
            temp_note1 = temp_note;
            if (update_voice & (note_values[15:8] == 8'b0)) begin
                count1 = 16'b0;
                gain1 = gain;
                next_state = `RELEASE;
		velocity1 = velocity;
            end
            else if (generate_next) begin
                count1 = count + 16'b1;
                gain1 = gain;
		velocity1 = velocity;
		next_state = curr_state;
            end
            else if ((count >= sustain) & zero_crossing) begin
                count1 = 16'b0;
		next_state = curr_state;
		velocity1 = velocity;
                if (gain == `MIN_GAIN) gain1 = gain;
                else gain1 = gain - 8'b1;
            end
            else begin
                next_state = curr_state;
                count1 = count;
                gain1 = gain;
                velocity1 = velocity;
            end
        end
        else begin
            temp_note1 = temp_note;
            if (gain == `MIN_GAIN) begin
                next_state = `OFF;
                gain1 = gain;
		count1 = count;
		velocity1 = velocity;
            end

            else if (generate_next) begin
                count1 = count + 16'b1;
                gain1 = gain;
		next_state = curr_state;
		velocity1 = velocity;
            end

            else if (((sustain_controller >= `SUS_MIN)
              & (count >= sustain))
              | ((sustain_controller < `SUS_MIN)
              & (count >= REL_TIME))
              & zero_crossing) begin

		next_state = curr_state;
		velocity1 = velocity;
                count1 = 16'b0;
                if (gain != `MIN_GAIN) gain1 = gain - 8'b1;
                else gain1 = gain;
            end

            else begin
                next_state = curr_state;
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
            case (controller_values[6:0])
              7'd64: sustain_controller1 = {1'b0, controller_values[13:7]};
              default: sustain_controller1 = sustain_controller;
            endcase
        end
        else sustain_controller1 = sustain_controller;
    end


    // This block updates the previous sample
    always @(*) begin
        if (reset) prev_sample1 = 16'sb0;
        else if (generate_next) prev_sample1 = sample_in;
        else prev_sample1 = prev_sample;
    end

endmodule
