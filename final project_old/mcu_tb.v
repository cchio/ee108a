module mcu_tb();
    reg clk, reset, play_button, next_button, song_done;
    wire play, reset_player;
    wire [1:0] song;

    mcu dut(
        .clk(clk),
        .reset(reset),
        .play_button(play_button),
        .next_button(next_button),
        .play(play),
        .reset_player(reset_player),
        .song(song),
        .song_done(song_done)
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // Tests
    initial begin
    
    	//do i have to do all these initializations?
		play_button = 0;
		next_button = 0;
		song_done = 0;
		
		//start playing, then pause
		play_button = 0;
		#50;
		play_button = 1;
		#10;
		play_button = 0;
		#50;
		play_button = 1;
		#10;
		play_button = 0;
		#50;
		
		//resume playing, then change to next song and play
		play_button = 1;
		#10;
		play_button = 0;
		#50;
		next_button = 1;
		#10;
		next_button = 0;
		#50;
		play_button = 1;
		#10;
		play_button = 0;
		#50;
		
		//change songs 3 more times, should loop back
		//to first song, then play
		next_button = 1;
		#10;
		next_button = 0;
		#50;		
		next_button = 1;
		#10;
		next_button = 0;
		#50;
		next_button = 1;
		#10;
		next_button = 0;
		#50;
		play_button = 1;
		#10;
		play_button = 0;
		#50;
		
		//song_done set to high, then resume playing
		song_done = 1;
		#10;
		song_done = 0;
		#50
		play_button = 1;
		#10;
		play_button = 0;
		#50;
		
		//reset set to high while playing
		//then resume playing
		reset = 1;
		#10;
		reset = 0;
		#50
		play_button = 1;
		#10;
		play_button = 0;
		#50;
		
		//stop playing, then next_song, then
		//reset set to high while not playing
		play_button = 1;
		#10;
		play_button = 0;
		#50;
		next_button = 1;
		#10;
		next_button = 0;
		#50;
		reset = 1;
		#10;
		reset = 0;
		#50
		
		$finish;
    end

endmodule
