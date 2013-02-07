module song_reader_tb();

	reg clk, reset, play, beat;

	reg [1:0] song;
	wire [5:0] note;
	wire [5:0] duration;
	wire song_done, new_note;

	song_reader dut(.clk(clk),
	        .reset(reset),
	        .play(play),
	        .song(song),
		.beat(beat),
        	.song_done(song_done),
		.note(note),
        	.duration(duration),
    	  	.new_note(new_note)
    	);

	// Clock and reset
	initial begin
       		clk = 1'b0;
        	reset = 1'b1;
        	repeat (4) #5 clk = ~clk;
        	reset = 1'b0;
        	forever #5 clk = ~clk;
    	end

	initial begin
        	beat = 1'b0;
        	forever #10 beat = ~beat;
	end

    
	// Tests
	initial begin
		$monitor("song: %b | note: %b | duration: %b | song_done: %b", song, note, duration, song_done);

		//First song

		play = 1;
		song = 2'b00;

		#100000
	
		play = 0;
		song = 2'b01;

		#200

		play = 1;
		song = 2'b10;
	
		#500

	$finish;



	end

endmodule


