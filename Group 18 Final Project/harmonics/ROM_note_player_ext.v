module ROM_note_player_ext(
    input clk,
    input reset,
    input play_enable,  // When high we play, when low we don't.
    input voice, //Low for piano, high for trumpet
    input [5:0] note_to_load,  // The note to play
    input [5:0] duration_to_load,  // The duration of the note to play
    input load_new_note,  // Tells us when we have a new note to load
    output done_with_note,  // When we are done with the note this stays high.
    input beat,  // This is our 1/48th second beat
    input generate_next_sample,  // Tells us when the codec wants a new sample
    output [15:0] sample_out,  // Our sample output
    output new_sample_ready  // Tells the codec when we've got a sample
);

    reg [5:0] n_new;
    wire [5:0] n_curr;
    reg [5:0] d_new;
    wire [5:0] d_curr;
    wire load;
    wire new_sample;
    wire [15:0] sample_curr;
    wire [15:0] sample_prev;
    wire done;
    wire done_and_zero;
    reg finished;
    wire which_voice;

    //Only finish at a zero crossing
    reg zero_crossing;

    dffr #(16) samp(.clk(clk), .r(reset), .d(sample_curr), .q(sample_prev));
    dffr rdy(.clk(clk), .r(reset), .d(new_sample), .q(new_sample_ready));
    dffr finish(.clk(clk), .r(reset), .d(finished), .q(done_with_note));

    always @(*) begin
	//Zero crossing
	if(sample_curr[15] != sample_prev[15])
		zero_crossing = 1'b1;
	else
		zero_crossing = 1'b0;
    end

    assign done_and_zero = done & (zero_crossing | (sample_prev == 16'b0));

    always @(*) begin
	if(done_and_zero)
		finished = 1'b1;
	else if(~done)
		finished = 1'b0;
	else
		finished = done_with_note;
    end

    //Flipflops for current note, duration, load, and instrument
    dffr #(6) note_ff(.clk(clk), .r(reset), .d(n_new), .q(n_curr));
    dffr #(6) duration_ff(.clk(clk), .r(reset), .d(d_new), .q(d_curr));
    dffr #(1) load_ff(.clk(clk), .r(reset), .d(load_new_note), .q(load));
    dffre instr(.clk(clk), .r(reset), .en(load_new_note), .d(voice), .q(which_voice));

    always @(*) begin
	if(load_new_note) begin
		n_new = note_to_load;
		d_new = duration_to_load;
	end

	else begin
		n_new = n_curr;
		d_new = d_curr;
	end
    end

    // Instance of the duration_timer module used to measure note duration
    // elapsed
    duration_timer2 dt(
        .clk(clk),
        .reset(reset),
        .beat(beat),
        .pause(~play_enable),
        .load_new_duration(load),
        .duration(d_curr),
        .done(done)
    );

    // frequency_rom instantiation
    wire [19:0] freq_rom_out, step_size;

    frequency_rom freq(
        .clk(clk),
        .addr(n_curr),
        .dout(freq_rom_out)
    );

    assign step_size = play_enable ? freq_rom_out : 20'b0;

    wire [15:0] sample1, sample2;
    wire new_sample1, new_sample2;
    // "Instantiation" of the piano_voice module

	piano_voice pv(
        .clk(clk),
        .reset(reset /*| done_and_zero*/),
        .load_new_note(load_new_note),
        .freq(step_size),
        .note_in(n_curr),
        .generate_next(generate_next_sample),
        .sample_out_ready(new_sample1),
        .sample(sample1),
	.done(done_and_zero)
    );

    // "Instantiation" of the trumpet_voice module

	trumpet_voice tv(
        .clk(clk),
        .reset(reset /*| done_and_zero*/),
        .load_new_note(load_new_note),
        .freq(step_size),
        .note_in(n_curr),
        .generate_next(generate_next_sample),
        .sample_out_ready(new_sample2),
        .sample(sample2),
	.done(done_and_zero)
    );

assign sample_curr = which_voice ? sample2 : sample1;
assign new_sample = which_voice ? new_sample2 : new_sample1;
assign sample_out = sample_prev;

endmodule
