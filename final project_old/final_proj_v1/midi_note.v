module midi_note (
    input clk,
    input reset,
    input generate_next,
    input [15:0] controller_values,
    input [15:0] note_values,
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


    // Create the harmonics

    sine_reader sin1(
        .clk(clk),
        .reset(reset),
        .zero(~note_playing),
        .step_size(step1),
        .generate_next(generate_next),
        .sample_ready(sample_ready),
        .sample(samp1)
    );

    sine_reader sin2(
        .clk(clk),
        .reset(reset),
        .zero(~note_playing),
        .step_size(step2),
        .generate_next(generate_next),
        .sample_ready(),
        .sample(samp2)
    );

    sine_reader sin3(
        .clk(clk),
        .reset(reset),
        .zero(~note_playing),
        .step_size(step3),
        .generate_next(generate_next),
        .sample_ready(),
        .sample(samp3)
    );

    sine_reader sin4(
        .clk(clk),
        .reset(reset),
        .zero(~note_playing),
        .step_size(step4),
        .generate_next(generate_next),
        .sample_ready(),
        .sample(samp4)
    );

    sine_reader sin5(
        .clk(clk),
        .reset(reset),
        .zero(~note_playing),
        .step_size(step5),
        .generate_next(generate_next),
        .sample_ready(),
        .sample(samp5)
    );

    sine_reader sin6(
        .clk(clk),
        .reset(reset),
        .zero(~note_playing),
        .step_size(step6),
        .generate_next(generate_next),
        .sample_ready(),
        .sample(samp6)
    );

    sine_reader sin7(
        .clk(clk),
        .reset(reset),
        .zero(~note_playing),
        .step_size(step7),
        .generate_next(generate_next),
        .sample_ready(),
        .sample(samp7)
    );

    sine_reader sin8(
        .clk(clk),
        .reset(reset),
        .zero(~note_playing),
        .step_size(step8),
        .generate_next(generate_next),
        .sample_ready(),
        .sample(samp8)
    );


    // Handle dynamics for each harmonic independently

    wire on1, on2, on3, on4, on5, on6, on7, on8;


    midi_dynamics dynamics1 (
        .clk(clk),
        .reset(reset),
        .update_voice(update_note),
        .update_all_voices(update_all_notes),
        .generate_next(generate_next),
        .note_values(note_values),
        .controller_values(controller_values),
        .sample_ready(sample_ready),
        .sample_in(samp1),
        .note(note1),
        .voice_on(on1),
        .sample_out_ready(sample_out_ready),
        .sample_out(dsamp1)
    );

    midi_dynamics dynamics2 (
        .clk(clk),
        .reset(reset),
        .update_voice(update_note),
        .update_all_voices(update_all_notes),
        .generate_next(generate_next),
        .note_values(note_values),
        .controller_values(controller_values),
        .sample_ready(sample_ready),
        .sample_in(samp2),
        .note(note2),
        .voice_on(on2),
        .sample_out_ready(),
        .sample_out(dsamp2)
    );

    midi_dynamics dynamics3 (
        .clk(clk),
        .reset(reset),
        .update_voice(update_note),
        .update_all_voices(update_all_notes),
        .generate_next(generate_next),
        .note_values(note_values),
        .controller_values(controller_values),
        .sample_ready(sample_ready),
        .sample_in(samp3),
        .note(note3),
        .voice_on(on3),
        .sample_out_ready(),
        .sample_out(dsamp3)
    );

    midi_dynamics dynamics4 (
        .clk(clk),
        .reset(reset),
        .update_voice(update_note),
        .update_all_voices(update_all_notes),
        .generate_next(generate_next),
        .note_values(note_values),
        .controller_values(controller_values),
        .sample_ready(sample_ready),
        .sample_in(samp4),
        .note(note4),
        .voice_on(on4),
        .sample_out_ready(),
        .sample_out(dsamp4)
    );

    midi_dynamics dynamics5 (
        .clk(clk),
        .reset(reset),
        .update_voice(update_note),
        .update_all_voices(update_all_notes),
        .generate_next(generate_next),
        .note_values(note_values),
        .controller_values(controller_values),
        .sample_ready(sample_ready),
        .sample_in(samp5),
        .note(note5),
        .voice_on(on5),
        .sample_out_ready(),
        .sample_out(dsamp5)
    );

    midi_dynamics dynamics6 (
        .clk(clk),
        .reset(reset),
        .update_voice(update_note),
        .update_all_voices(update_all_notes),
        .generate_next(generate_next),
        .note_values(note_values),
        .controller_values(controller_values),
        .sample_ready(sample_ready),
        .sample_in(samp6),
        .note(note6),
        .voice_on(on6),
        .sample_out_ready(),
        .sample_out(dsamp6)
    );

    midi_dynamics dynamics7 (
        .clk(clk),
        .reset(reset),
        .update_voice(update_note),
        .update_all_voices(update_all_notes),
        .generate_next(generate_next),
        .note_values(note_values),
        .controller_values(controller_values),
        .sample_ready(sample_ready),
        .sample_in(samp7),
        .note(note7),
        .voice_on(on7),
        .sample_out_ready(),
        .sample_out(dsamp7)
    );

    midi_dynamics dynamics8 (
        .clk(clk),
        .reset(reset),
        .update_voice(update_note),
        .update_all_voices(update_all_notes),
        .generate_next(generate_next),
        .note_values(note_values),
        .controller_values(controller_values),
        .sample_ready(sample_ready),
        .sample_in(samp8),
        .note(note8),
        .voice_on(on8),
        .sample_out_ready(),
        .sample_out(dsamp8)
    );

    assign note_playing = on1 || on2 || on3 || on4 || on5 || on6 || on7 || on8;
    assign note = note1 | note2 | note3 | note4 | note5 | note6 | note7 | note8;


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
        .sample(sample_out)
    );

endmodule
