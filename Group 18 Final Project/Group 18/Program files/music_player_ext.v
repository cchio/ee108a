//
//  music_player module
//
//  This music_player module connects up the MCU, song_reader, note_player,
//  beat_generator, and codec_conditioner. It provides an output that indicates
//  a new sample (new_sample_generated) which will be used in lab 5.
//

module music_player(
    // Standard system clock and reset
    input clk,
    input reset,

    // Our debounced and one-pulsed button inputs.
    input play_button,
    input next_button,

    // Our input from the DIP switches
    input [2:0] sw,

    // The raw new_frame signal from the ac97_if codec.
    input new_frame,

    // This output must go high for one cycle when a new sample is generated.
    output wire new_sample_generated,

    // Our final output sample to the codec. This needs to be synced to
    // new_frame.
    output wire [15:0] sample_out
);
    // The BEAT_COUNT is parameterized so you can reduce this in simulation.
    // If you reduce this to 100 your simulation will be 10x faster.
    parameter BEAT_COUNT = 10;

//   
//  ****************************************************************************
//      MCU
//  ****************************************************************************
//  
	wire [1:0] song;
	wire song_done;
	wire reset_player;
	wire play;
	mcu mcu(
		.clk(clk),
        .reset(reset),
    	.play_button(play_button),
    	.next_button(next_button),
    	.play(play),
    	.reset_player(reset_player),
    	.song(song),
    	.song_done(song_done)
	);

//   
//  ****************************************************************************
//      Song Reader
//  ****************************************************************************
//  
	wire player_available;	
	wire beat;
	//wire note_done;
	wire [5:0] note;
	wire [5:0] duration;
	wire new_note;
	song_reader song_reader(  	
		.clk(clk),
        	.reset(reset | reset_player),
		.play(play),
		.song(song), 
		.beat(beat),
		.player_available(player_available),
		//.note_done(note_done),
		.song_done(song_done),
		.note(note),
		.duration(duration),
		.new_note(new_note)
	);

//   
//  ****************************************************************************
//      Chord module
//  ****************************************************************************
//  

    wire generate_next_sample;
    wire [15:0] note_sample;
    wire note_sample_ready;
    chords chord(
        .clk(clk),
        .reset(reset | reset_player),
        .play(play),
	.sw(sw),
        .note(note),
        .duration(duration),
        .new_note(new_note),
        //.done_with_note(note_done),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(note_sample),
        .new_sample_ready(note_sample_ready),
	.player_available(player_available)
    );
      
//   
//  ****************************************************************************
//      Beat Generator
//  ****************************************************************************
//  By default this will divide the generate_next_sample signal (48kHz from the
//  codec's new_frame input) down by 1000, to 48Hz. If you change the BEAT_COUNT
//  parameter when instantiating this you can change it for simulation.
//  
    beat_generator #(.WIDTH(10), .STOP(BEAT_COUNT)) beat_generator(
        .clk(clk),
        .reset(reset),
        .en(generate_next_sample),
        .beat(beat)
    );

//  
//  ****************************************************************************
//      Codec Conditioner
//  ****************************************************************************
//  
    assign new_sample_generated = generate_next_sample;
    codec_conditioner codec_conditioner(
        .clk(clk),
        .reset(reset),
        .new_sample_in(note_sample),
        .latch_new_sample_in(note_sample_ready),
        .generate_next_sample(generate_next_sample),
        .new_frame(new_frame),
        .valid_sample(sample_out)
    );

endmodule
