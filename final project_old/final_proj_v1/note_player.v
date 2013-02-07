module note_player(
    input clk,
    input reset,
    input play_enable,  // When high we play, when low we don't.
    input [5:0] note_to_load,  // The note to play
    input [5:0] duration_to_load,  // The duration of the note to play
    input load_new_note,  // Tells us when we have a new note to load
    output done_with_note,  // When we are done with the note this stays high.
    input beat,  // This is our 1/48th second beat
    input generate_next_sample,  // Tells us when the codec wants a new sample
    output [15:0] sample_out,  // Our sample output
    output new_sample_ready  // Tells the codec when we've got a sample
);

    // Instance of the duration_timer module used to measure note duration
    // elapsed
    duration_timer dt(
        .clk(clk),
        .reset(reset),
        .beat(beat),
        .pause(~play_enable),
        .load_new_duration(load_new_note),
        .duration(duration_to_load),
        .done(done_with_note)
    );

    // frequency_rom instantiation
    wire [19:0] freq_rom_out, step_size;

    frequency_rom freq(
        .clk(clk),
        .addr(note_to_load),
        .dout(freq_rom_out)
    );

    assign step_size = play_enable ? freq_rom_out : 20'b0;

    // Instantiation of the sine_reader module
    sine_reader sin(
        .clk(clk),
        .reset(reset),
        .zero(1'b0),
        .step_size(step_size),
        .generate_next(generate_next_sample),
        .sample_ready(new_sample_ready),
        .sample(sample_out)
    );

endmodule
