module lab4_top(
    // Clock
    input clk,
    // AC97 interface
    input  AC97Clk,            // AC97 clock (~12 Mhz)
    input  SData_In,           // Serial data in (record data and status)
    output AC97Reset_n,        // Reset signal for AC97 controller/clock
    output SData_Out,          // Serial data out (control and playback data)
    output Sync,               // AC97 sync signal
    // Push button interface
    input  left_button,
    input  right_button,
    input  up_button,
    //DIP switches
    input [2:0] sw,
    // LEDs
    output wire [3:0] leds_l,
    output wire [3:0] leds_r
);
    // button_press_unit's WIDTH parameter is exposed here so that you can
    // reduce it in simulation.  Setting it to 1 effectively disables it.
    parameter BPU_WIDTH = 20;
    // The BEAT_COUNT is parameterized so you can reduce this in simulation.
    // If you reduce this to 100 your simulation will be 10x faster.
    parameter BEAT_COUNT = 1000;

    // Our reset
    wire reset = up_button;

//   
//  ****************************************************************************
//      Button processor units
//  ****************************************************************************
//  
    wire play;
    button_press_unit #(.WIDTH(BPU_WIDTH)) play_button_press_unit(
        .clk(clk),
        .reset(reset),
        .in(left_button),
        .out(play)
    );

    wire next;
    button_press_unit #(.WIDTH(BPU_WIDTH)) next_button_press_unit(
        .clk(clk),
        .reset(reset),
        .in(right_button),
        .out(next)
    );
       
//   
//  ****************************************************************************
//      The music player
//  ****************************************************************************
//         
    wire new_frame;
    wire [15:0] codec_sample;
    wire new_sample;
    music_player #(.BEAT_COUNT(BEAT_COUNT)) music_player(
        .clk(clk),
        .reset(reset),
        .play_button(play),
        .next_button(next),
	.sw(sw),
        .new_frame(new_frame), 
        .sample_out(codec_sample),
        .new_sample_generated(new_sample)
    );

//   
//  ****************************************************************************
//      Codec interface
//  ****************************************************************************
//  
    // Output the sample onto the LEDs for the fun of it.
    //assign leds_l = codec_sample[15:12];
    //assign leds_r = codec_sample[15:12];

	//Make sure the codec is playing
      	assign {leds_l[3], leds_r} = codec_sample[15:11];
	//See which switches are on
	assign leds_l[2:0] = sw;


	/* ac97_if codec(
        .ClkIn(clk),
        .PCM_Playback_Left(codec_sample),   // Set these two to different
        .PCM_Playback_Right(codec_sample),  // samples to have stereo audio!
        .PCM_Record_Left(),
        .PCM_Record_Right(),
        .New_Frame(new_frame),  // Asserted each sample
        .AC97Reset_n(AC97Reset_n),
        .AC97Clk(AC97Clk),
        .Sync(Sync),
        .SData_Out(SData_Out),
        .SData_In(SData_In)
    );*/


        ac97_if codec(
        .ClkIn(clk),
        .Reset(1'b0), // Changed (new port)
        .PCM_Playback_Left(codec_sample),
        .PCM_Playback_Right(codec_sample),
        .PCM_Record_Left(),
        .PCM_Record_Right(),
        .PCM_Record_Valid(), // Changed (new port)
        .PCM_Playback_Accept(new_frame),  // Changed (used to be called New_Frame)
        .AC97Reset_n(AC97Reset_n),
        .AC97Clk(AC97Clk),
        .Sync(Sync),
        .SData_Out(SData_Out),
        .SData_In(SData_In),
        .Debug() // Changed (new port)
    );

endmodule
