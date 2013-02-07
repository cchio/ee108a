module midi_note (
    input clk,
    input reset,
    input generate_next,
    input [13:0] controller_values,
    input [13:0] note_values,
    input update_all_notes,
    input update_note,

    output note_playing,
    output sample_out_ready,
    output signed [15:0] sample_out
);

    wire signed [15:0] samp1, samp2, samp3, samp4, samp5, samp6, samp7,
      samp8;
    wire signed [15:0] dsamp1, dsamp2, dsamp3, dsamp4, dsamp5, dsamp6,
      dsamp7, dsamp8;
    wire sample_ready;
    wire [19:0] freq;
    wire [5:0] note, note1, note2, note3, note4, note5, note6, note7, note8;


    // Obtain the fundamental frequency step size

    frequency_rom freq_rom (
        .clk(clk),
        .addr(note),
        .dout(freq)
    );


    // Create the step sizes of the different harmonics

    wire [22:0] s1, s2, s3, s4, s5, s6, s7, s8;

    assign s1 = {3'b0,freq};
    assign s2 = s1 << 1;
    assign s3 = s2 + s1;
    assign s4 = s3 + s1;
    assign s5 = s4 + s1;
    assign s6 = s5 + s1;
    assign s7 = s6 + s1;
    assign s8 = s7 + s1;


    // Circumvent imprecision due to overflow

    wire [19:0] step1, step2, step3, step4, step5, step6, step7, step8;

    assign step1 = freq;
    assign step2 = (s2[22:20] == 3'b0) ? s2[19:0] : 20'b0;
    assign step3 = (s3[22:20] == 3'b0) ? s3[19:0] : 20'b0;
    assign step4 = (s4[22:20] == 3'b0) ? s4[19:0] : 20'b0;
    assign step5 = (s5[22:20] == 3'b0) ? s5[19:0] : 20'b0;
    assign step6 = (s6[22:20] == 3'b0) ? s6[19:0] : 20'b0;
    assign step7 = (s7[22:20] == 3'b0) ? s7[19:0] : 20'b0;
    assign step8 = (s8[22:20] == 3'b0) ? s8[19:0] : 20'b0;

    wire [19:0] step_size1, step_size2, step_size3, step_size4, step_size5,
                step_size6, step_size7, step_size8;
    wire gen_next;
    wire sample_ready1;
    wire signed [15:0] sample_out1;

    dffr #(20) st1(.clk(clk), .r(reset), .d(step1), .q(step_size1));
    dffr #(20) st2(.clk(clk), .r(reset), .d(step2), .q(step_size2));
    dffr #(20) st3(.clk(clk), .r(reset), .d(step3), .q(step_size3));
    dffr #(20) st4(.clk(clk), .r(reset), .d(step4), .q(step_size4));
    dffr #(20) st5(.clk(clk), .r(reset), .d(step5), .q(step_size5));
    dffr #(20) st6(.clk(clk), .r(reset), .d(step6), .q(step_size6));
    dffr #(20) st7(.clk(clk), .r(reset), .d(step7), .q(step_size7));
    dffr #(20) st8(.clk(clk), .r(reset), .d(step8), .q(step_size8));

    dffr  gen(.clk(clk), .r(reset), .d(generate_next), .q(gen_next));

    dff #(.WIDTH(16)) sample_out_ff (
        .clk(clk),
        .d(sample_out1),
        .q(sample_out)
    );

    dff sample_out_ready_ff (
        .clk(clk),
        .d(sample_ready1),
        .q(sample_out_ready)
    );


    // Create the harmonics

    midi_wave_reader wave (
        .clk(clk),
        .reset(reset),
        .zero(~note_playing),
        .generate_next(gen_next),
        .step1(step_size1),
        .step2(step_size2),
        .step3(step_size3),
        .step4(step_size4),
        .step5(step_size5),
        .step6(step_size6),
        .step7(step_size7),
        .step8(step_size8),
        .samples_ready(sample_ready),
        .sample1(samp1),
        .sample2(samp2),
        .sample3(samp3),
        .sample4(samp4),
        .sample5(samp5),
        .sample6(samp6),
        .sample7(samp7),
        .sample8(samp8)
    );


    // Handle dynamics for each harmonic independently

    midi_dynamics dynamics (
        .clk(clk),
        .reset(reset),
        .generate_next(generate_next),
        .update_voice(update_note),
        .update_all_voices(update_all_notes),
        .controller_values(controller_values),
        .note_values(note_values),
        .samples_in_ready(sample_ready),
        .sample_in1(samp1),
        .sample_in2(samp2),
        .sample_in3(samp3),
        .sample_in4(samp4),
        .sample_in5(samp5),
        .sample_in6(samp6),
        .sample_in7(samp7),
        .sample_in8(samp8),

        .voice_on(note_playing),
        .note(note),
        .samples_out_ready(sample_ready1),
        .sample_out1(dsamp1),
        .sample_out2(dsamp2),
        .sample_out3(dsamp3),
        .sample_out4(dsamp4),
        .sample_out5(dsamp5),
        .sample_out6(dsamp6),
        .sample_out7(dsamp7),
        .sample_out8(dsamp8)
    );


    // Weight the samples
    // Expand samples by 8 bits
    // Multiply by weights and add,
    // then divide by 128

    piano_weight weights (
        .s1(dsamp1),
        .s2(dsamp2),
        .s3(dsamp3),
        .s4(dsamp4),
        .s5(dsamp5),
        .s6(dsamp6),
        .s7(dsamp7),
        .s8(dsamp8),
        .sample(sample_out1)
    );

endmodule
