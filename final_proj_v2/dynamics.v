module dynamics
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
    input load_new_note,
    input done,
    input samples_in_ready,
    input signed [15:0] sample_in1,
    input signed [15:0] sample_in2,
    input signed [15:0] sample_in3,
    input signed [15:0] sample_in4,
    input signed [15:0] sample_in5,
    input signed [15:0] sample_in6,
    input signed [15:0] sample_in7,
    input signed [15:0] sample_in8,

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

    wire [7:0] gain1, gain2, gain3, gain4, gain5, gain6, gain7, gain8;
    wire decay1, decay2, decay3, decay4, decay5, decay6, decay7, decay8;


    // Dynamics calculation module

    dynamics_calc2 calc (
        .clk(clk),
        .reset(reset),
        .samples_in_ready(samples_in_ready),
        .velocity(8'd127),

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

    harmonic_dynamics
    #(ATTACK_TIME1, SUSTAIN_TIME1, REL_TIME1)
    h1 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .load_new_note(load_new_note),
        .done(done),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in1),

        .gain(gain1),
        .decay_type(decay1)
    );

    harmonic_dynamics
    #(ATTACK_TIME2, SUSTAIN_TIME2, REL_TIME2)
    h2 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .load_new_note(load_new_note),
        .done(done),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in2),

        .gain(gain2),
        .decay_type(decay2)
    );

    harmonic_dynamics
    #(ATTACK_TIME3, SUSTAIN_TIME3, REL_TIME3)
    h3 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .load_new_note(load_new_note),
        .done(done),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in3),

        .gain(gain3),
        .decay_type(decay3)
    );

    harmonic_dynamics
    #(ATTACK_TIME4, SUSTAIN_TIME4, REL_TIME4)
    h4 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .load_new_note(load_new_note),
        .done(done),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in4),

        .gain(gain4),
        .decay_type(decay4)
    );

    harmonic_dynamics
    #(ATTACK_TIME5, SUSTAIN_TIME5, REL_TIME5)
    h5 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .load_new_note(load_new_note),
        .done(done),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in5),

        .gain(gain5),
        .decay_type(decay5)
    );

    harmonic_dynamics
    #(ATTACK_TIME6, SUSTAIN_TIME6, REL_TIME6)
    h6 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .load_new_note(load_new_note),
        .done(done),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in6),

        .gain(gain6),
        .decay_type(decay6)
    );

    harmonic_dynamics
    #(ATTACK_TIME7, SUSTAIN_TIME7, REL_TIME7)
    h7 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .load_new_note(load_new_note),
        .done(done),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in7),

        .gain(gain7),
        .decay_type(decay7)
    );

    harmonic_dynamics
    #(ATTACK_TIME8, SUSTAIN_TIME8, REL_TIME8)
    h8 (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .load_new_note(load_new_note),
        .done(done),
        .sample_ready(samples_in_ready),
        .sample_in(sample_in8),

        .gain(gain8),
        .decay_type(decay8)
    );

endmodule
