module music_player_tb();
    reg clk, reset, next_button, play_button;
    reg [2:0] switches;
    wire new_frame;
    wire [15:0] sample;

    music_player #(.BEAT_COUNT(500)) music_player(
        .clk(clk),
        .reset(reset),
	.sw(switches),
        .next_button(next_button),
        .play_button(play_button),
        .new_frame(new_frame),
        .sample_out(sample)
    );

    // AC97 interface
    wire AC97Reset_n;        // Reset signal for AC97 controller/clock
    wire SData_Out;          // Serial data out (control and playback data)
    wire Sync;               // AC97 sync signal

    // Our codec simulator
   /* ac97_if codec(
        .ClkIn(clk),
        .PCM_Playback_Left(sample),   // Set these two to different
        .PCM_Playback_Right(sample),  // samples to have stereo audio!
        .PCM_Record_Left(),
        .PCM_Record_Right(),
        .New_Frame(new_frame),  // Asserted each sample
        .AC97Reset_n(AC97Reset_n),
        .AC97Clk(1'b0),
        .Sync(Sync),
        .SData_Out(SData_Out),
        .SData_In(1'b0)
    );*/

	ac97_if codec(
        .ClkIn(clk),
        .Reset(reset), // Changed (new port)
        .PCM_Playback_Left(sample),
        .PCM_Playback_Right(sample),
        .PCM_Record_Left(),
        .PCM_Record_Right(),
        .PCM_Record_Valid(), // Changed (new port)
        .PCM_Playback_Accept(new_frame),  // Changed (used to be called New_Frame)
        .AC97Reset_n(AC97Reset_n),
        .AC97Clk(1'b0),
        .Sync(Sync),
        .SData_Out(SData_Out),
        .SData_In(1'b0),
        .Debug() // Changed (new port)
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
    integer delay;
    initial begin

	switches = 3'b0;
        //delay = 2000000;
	delay = 500000;
        play_button = 1'b0;
        next_button = 1'b0;
        @(negedge reset);
        @(negedge clk);

	//play_button = 1'b1;
	#5
	//play_button = 1'b0;

        repeat (25) begin
            @(negedge clk);
        end 

        // Start playing
        $display("Starting playing song 0...");
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;


	//repeat (delay * 12) begin
        repeat (delay*3/8) begin
            @(negedge clk);
        end

	//1 switch on
	switches = 3'b111;
	repeat (delay*3/8) begin
            @(negedge clk);
        end

	//2 switches on
	switches = 3'b100;
	repeat (delay*3/8) begin
            @(negedge clk);
        end

	//3 switches on
	switches = 3'b101;
	repeat (delay*3/8) begin
            @(negedge clk);
        end

      /*  // Pause  
        $display("Pause...");
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay/4) begin
            @(negedge clk);
        end
*/

        // Play 
        $display("Resume playing song 0..."); 
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay*2) begin
            @(negedge clk);
        end

/*

     // Next Song  
        $display("Next song...");
        @(negedge clk);
        next_button = 1'b1;
        @(negedge clk);
        next_button = 1'b0;

        repeat (delay/8) begin
            @(negedge clk);
        end


     // Play song 1
        $display("Starting playing song 1...");  
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay*6) begin
            @(negedge clk);
        end
    /*    
     // Pause  
        $display("Pause...");
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay) begin
            @(negedge clk);
        end
        
     // Resume
        $display("Resume playing song 1 till finish...");  
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay*6) begin
            @(negedge clk);
        end
        
     // Play song 2
        $display("Starting playing song 2...");  
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay*6) begin
            @(negedge clk);
        end
        
    //  Next button...  
        $display("Next button...");
        @(negedge clk);
        next_button = 1'b1;
        @(negedge clk);
        next_button = 1'b0;

        repeat (delay/4) begin
            @(negedge clk);
        end
        
     // Play song 3
        $display("Starting playing song 3...");
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay*6) begin
            @(negedge clk);
        end    

    //  Next button...  
        $display("Next button...");
        @(negedge clk);
        next_button = 1'b1;
        @(negedge clk);
        next_button = 1'b0;

        repeat (delay/4) begin
            @(negedge clk);
        end
        
     // Play song 4
        $display("Starting playing song 3...");
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay*12) begin
            @(negedge clk);
        end   
        
    // Reset, should loop back to song 1
        $display("Reset...");
        @(negedge clk);
        reset = 1'b1;
        @(negedge clk);
        reset = 1'b0;

        repeat (delay/4) begin
            @(negedge clk);
        end
        
     // Play song 1
        $display("Starting playing song 1...");
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay*3) begin
            @(negedge clk);
        end 
*/

        $finish;
    end


endmodule
