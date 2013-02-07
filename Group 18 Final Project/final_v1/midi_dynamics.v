module midi_dynamics
    #(parameter ATTACK_TIME1 = 75,
    parameter SUSTAIN_TIME1 = 1400,
    parameter REL_TIME1 = 150,
    parameter ATTACK_TIME2 = 75,
    parameter SUSTAIN_TIME2 = 1400,
    parameter REL_TIME2 = 150,
    parameter ATTACK_TIME3 = 75,
    parameter SUSTAIN_TIME3 = 1400,
    parameter REL_TIME3 = 150,
    parameter ATTACK_TIME4 = 75,
    parameter SUSTAIN_TIME4 = 1400,
    parameter REL_TIME4 = 150,
    parameter ATTACK_TIME5 = 75,
    parameter SUSTAIN_TIME5 = 1400,
    parameter REL_TIME5 = 150,
    parameter ATTACK_TIME6 = 75,
    parameter SUSTAIN_TIME6 = 1400,
    parameter REL_TIME6 = 150,
    parameter ATTACK_TIME7 = 75,
    parameter SUSTAIN_TIME7 = 1400,
    parameter REL_TIME7 = 150,
    parameter ATTACK_TIME8 = 75,
    parameter SUSTAIN_TIME8 = 1400,
    parameter REL_TIME8 = 150)
(
    input clk,
    input reset,
    input generate_next,
    input update_voice,
    input update_all_voices,
    input [13:0] controller_values,
    input [13:0] note_values,
    input samples_in_ready,
    input signed [15:0] sample_in1,
    input signed [15:0] sample_in2,
    input signed [15:0] sample_in3,
    input signed [15:0] sample_in4,
    input signed [15:0] sample_in5,
    input signed [15:0] sample_in6,
    input signed [15:0] sample_in7,
    input signed [15:0] sample_in8,

    output voice_on,
    output [5:0] note,
    output samples_out_ready,
    output signed [15:0] sample_out1,
    output signed [15:0] sample_out2,
    output signed [15:0] sample_out3,
    output signed [15:0] sample_out4,
    output signed [15:0] sample_out5,
    output signed [15:0] sample_out6,
    output signed [15:0] sample_out7,
    output signed [15:0] sample_out8
);

    wire on1, on2, on3, on4, on5, on6, on7, on8;
    wire [5:0] note1, note2, note3, note4, note5, note6, note7, note8;
    wire [15:0] sustain_inc;
    wire [7:0] velocity, gain1, gain2, gain3, gain4, gain5, gain6, gain7, gain8;
    wire decay1, decay2, decay3, decay4, decay5, decay6, decay7, decay8;


    // assigns
    assign voice_on = on1 || on2 || on3 || on4 || on5 || on6 || on7 || on8;
    assign note = note1 | note2 | note3 | note4 | note5 | note6 | note7 | note8;


    // Module for calculating sustain length variation for each note

    sustain_variation sustain (
        .clk(clk),
        .reset(reset),
        .note(note),
        .count(sustain_inc)
    );


    // Dynamics calculation module

    dynamics_calc calc (
        .clk(clk),
        .reset(reset),
        .samples_in_ready(samples_in_ready),
        .velocity(velocity),

        .sample_in1(sample_in1),
        .gain1(gain1),
        .decay_type1(decay1),

        .sample_in2(sample_in2),
        .gain2(gain2),
        .decay_type2(decay2),

        .sample_in3(sample_in3),
        .gain3(gain3),
        .decay_type3(decay3),

        .sample_in4(sample_in4),
        .gain4(gain4),
        .decay_type4(decay4),

        .sample_in5(sample_in5),
        .gain5(gain5),
        .decay_type5(decay5),

        .sample_in6(sample_in6),
        .gain6(gain6),
        .decay_type6(decay6),

        .sample_in7(sample_in7),
        .gain7(gain7),
        .decay_type7(decay7),

        .sample_in8(sample_in8),
        .gain8(gain8),
        .decay_type8(decay8),

        .samples_out_ready(samples_out_ready),
        .sample_out1(sample_out1),
        .sample_out2(sample_out2),
        .sample_out3(sample_out3),
        .sample_out4(sample_out4),
        .sample_out5(sample_out5),
        .sample_out6(sample_out6),
        .sample_out7(sample_out7),
        .sample_out8(sample_out8)
    );


    // Modules to handle dynamics timing for each harmonic

    midi_harmonic_dynamics 
    #(ATTACK_TIME1, SUSTAIN_TIME1, REL_TIME1)
    h1 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .update_voice(update_voice),
        .update_all_voices(update_all_voices),
        .controller_values(controller_values),
        .note_values(note_values),
        .sustain_inc(sustain_inc),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in1),

        .voice_on(on1),
        .note(note1),
        .velocity(velocity),
        .gain(gain1),
        .decay_type(decay1)
    );

    midi_harmonic_dynamics 
    #(ATTACK_TIME2, SUSTAIN_TIME2, REL_TIME2)
    h2 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .update_voice(update_voice),
        .update_all_voices(update_all_voices),
        .controller_values(controller_values),
        .note_values(note_values),
        .sustain_inc(sustain_inc),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in2),

        .voice_on(on2),
        .note(note2),
        .velocity(),
        .gain(gain2),
        .decay_type(decay2)
    );

    midi_harmonic_dynamics 
    #(ATTACK_TIME3, SUSTAIN_TIME3, REL_TIME3)
    h3 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .update_voice(update_voice),
        .update_all_voices(update_all_voices),
        .controller_values(controller_values),
        .note_values(note_values),
        .sustain_inc(sustain_inc),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in3),

        .voice_on(on3),
        .note(note3),
        .velocity(),
        .gain(gain3),
        .decay_type(decay3)
    );

    midi_harmonic_dynamics 
    #(ATTACK_TIME4, SUSTAIN_TIME4, REL_TIME4)
    h4 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .update_voice(update_voice),
        .update_all_voices(update_all_voices),
        .controller_values(controller_values),
        .note_values(note_values),
        .sustain_inc(sustain_inc),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in4),

        .voice_on(on4),
        .note(note4),
        .velocity(),
        .gain(gain4),
        .decay_type(decay4)
    );

    midi_harmonic_dynamics 
    #(ATTACK_TIME5, SUSTAIN_TIME5, REL_TIME5)
    h5 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .update_voice(update_voice),
        .update_all_voices(update_all_voices),
        .controller_values(controller_values),
        .note_values(note_values),
        .sustain_inc(sustain_inc),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in5),

        .voice_on(on5),
        .note(note5),
        .velocity(),
        .gain(gain5),
        .decay_type(decay5)
    );

    midi_harmonic_dynamics 
    #(ATTACK_TIME6, SUSTAIN_TIME6, REL_TIME6)
    h6 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .update_voice(update_voice),
        .update_all_voices(update_all_voices),
        .controller_values(controller_values),
        .note_values(note_values),
        .sustain_inc(sustain_inc),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in6),

        .voice_on(on6),
        .note(note6),
        .velocity(),
        .gain(gain6),
        .decay_type(decay6)
    );

    midi_harmonic_dynamics 
    #(ATTACK_TIME7, SUSTAIN_TIME7, REL_TIME7)
    h7 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .update_voice(update_voice),
        .update_all_voices(update_all_voices),
        .controller_values(controller_values),
        .note_values(note_values),
        .sustain_inc(sustain_inc),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in7),

        .voice_on(on7),
        .note(note7),
        .velocity(),
        .gain(gain7),
        .decay_type(decay7)
    );

    midi_harmonic_dynamics 
    #(ATTACK_TIME8, SUSTAIN_TIME8, REL_TIME8)
    h8 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .update_voice(update_voice),
        .update_all_voices(update_all_voices),
        .controller_values(controller_values),
        .note_values(note_values),
        .sustain_inc(sustain_inc),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in8),

        .voice_on(on8),
        .note(note8),
        .velocity(),
        .gain(gain8),
        .decay_type(decay8)
    );

endmodule
