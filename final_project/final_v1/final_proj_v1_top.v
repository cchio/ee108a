module final_proj_v1_top(
    // Clock
    input clk,
    // AC97 interface
    input  AC97Clk,            // AC97 clock (~12 Mhz)
    input  SData_In,           // Serial data in (record data and status)
    output AC97Reset_n,        // Reset signal for AC97 controller/clock
    output SData_Out,          // Serial data out (control and playback data)
    output Sync,               // AC97 sync signal
    // Push button and toggle switch interface
    input  left_button,
    input  right_button,
    input  up_button,
    input mode_sel,
    // LEDs
    output wire [3:0] leds_l,
    output wire [3:0] leds_r,
    // DVI Interface
    output chip_hsync,
    output chip_vsync,
    output [11:0] chip_data,
    output chip_reset,
    output chip_data_enable,
    output xclk,
    output xclk_n,
    // I2C
    inout  scl,
    inout  sda,
    // RS232 interface
    input RXD_pin,
    output TXD_pin
);  
    // button_press_unit's WIDTH parameter is exposed here so that you can
    // reduce it in simulation.  Setting it to 1 effectively disables it.
    parameter BPU_WIDTH = 20;
    // The BEAT_COUNT is parameterized so you can reduce this in simulation.
    // If you reduce this to 100 your simulation will be 10x faster.
    parameter BEAT_COUNT = 1000;

    // Our reset
    wire reset = up_button;
   
    // These signals are for determining which color to display
    wire [10:0] x;  // [0..1279]
    wire [9:0]  y;  // [0..1023]     
    // Color to display at the given x,y
    wire [7:0]  r, g, b;
 
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
//      The music player, midi player and RS-232 modules
//  ****************************************************************************
//         
    wire new_frame, rx_flag;
    wire [7:0] data_byte;
    wire [15:0] codec_sample1, codec_sample2, flopped_sample;
    wire new_sample1, new_sample2, flopped_new_sample;

    // music_player (active with mode_sel = 0)
    music_player #(.BEAT_COUNT(BEAT_COUNT)) music_player(
        .clk(clk),
        .reset(reset | mode_sel),
        .play_button(play),
        .next_button(next),
        .new_frame(new_frame), 
        .sample_out(codec_sample1),
        .new_sample_generated(new_sample1)
    );

    // midi_player (active with mode_sel = 1)
    midi_player midi_synth (
        .clk(clk),
        .reset(reset | ~mode_sel),
        .new_byte(data_byte),
        .new_byte_ready(rx_flag),
        .new_frame(new_frame),
        .sample_out(codec_sample2),
        .new_sample_generated(new_sample2)
        .playing({leds_l,leds_r})
    );

    // RS-232 interface
    rs232 rs232_com (
        .clk(clk),
        .reset(reset),
        .rx_pin(RXD_pin),
        .rx_flag(rx_flag),
        .rx_data_byte(data_byte),
        .tx_busy(),
        .tx_byte(),
        .tx_pin(TXD_pin),
        .tx_data_ready()
    );

    dff #(.WIDTH(17)) sample_reg (
        .clk(clk),
        .d(mode_sel ? {new_sample1, codec_sample1}
          : {new_sample2, codec_sample2}),
        .q({flopped_new_sample, flopped_sample})
    );

//   
//  ****************************************************************************
//      Wave display
//  ****************************************************************************
//  
     wave_display_top wd(
         .clk(clk),
         .reset(reset),
         .x(x),
         .y(y),
         .valid(chip_hsync && chip_vsync),
         .vsync(chip_vsync),
         .r(r),
         .g(g),
         .b(b),
         .sample(flopped_sample),
         .new_sample(flopped_new_sample)
     );

//   
//  ****************************************************************************
//      Codec interface
//  ****************************************************************************
//  
    ac97_if codec(
        .ClkIn(clk),
        .PCM_Playback_Left(mode_sel ? codec_sample2:codec_sample1),   // Set these two to different
        .PCM_Playback_Right(mode_sel ? codec_sample2:codec_sample1),  // samples to have stereo audio!
        .PCM_Record_Left(),
        .PCM_Record_Right(),
        .New_Frame(new_frame),  // Asserted each sample
        .AC97Reset_n(AC97Reset_n),
        .AC97Clk(AC97Clk),
        .Sync(Sync),
        .SData_Out(SData_Out),
        .SData_In(SData_In)
    );

//   
//  ****************************************************************************
//      Display management
//  ****************************************************************************
//  
    /* blinking leds to show life */
    wire [26:0] led_counter;

    dff #(.WIDTH (27)) led_div (
        .clk (clk),
        .d (led_counter + 27'd1),
        .q (led_counter)
    );

    dvi_controller_top ctrl(
        .clk    (clk),
        .enable (1'b1),
        .reset  (reset),
        .r      (r),
        .g      (g),
        .b      (b),

        .chip_data_enable (chip_data_enable),
        .chip_hsync       (chip_hsync),
        .chip_vsync       (chip_vsync),
        .chip_reset       (chip_reset),
        .chip_data        (chip_data),
        .xclk             (xclk),
        .xclk_n           (xclk_n),
        .x                (x),
        .y                (y)
    );
 
    // I2C controller to configure dvi interface
    i2c_emulator i2c_controller(
        .clk (clk),
        .rst (reset),

        .scl (scl),
        .sda (sda)
    );

endmodule
