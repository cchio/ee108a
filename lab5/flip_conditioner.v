module flip_conditioner (
   input clk,
   input reset,
   input wave_display_idle,
   input wave_capture_fsm_is_active,
   output flip_read_index
);

    wire flip_condition = wave_display_idle & ~wave_capture_fsm_is_active;
    wire flip_condition_pulsed;
    
    one_pulse flip_condition_pulser (
        .clk(clk),
        .reset(reset),
        .in(flip_condition),
        .out(flip_condition_pulsed)
    );

    wire buffer_finished;
    reg next_buffer_finished;
    always @(*) begin
        if (wave_capture_fsm_is_active)
            next_buffer_finished = 1'b1;
        else if (buffer_finished)
            next_buffer_finished = flip_condition_pulsed;
        else
            next_buffer_finished = 1'b0;
    end

    dffr buffer_finished_flop (
        .clk(clk),
        .r(reset),
        .d(next_buffer_finished),
        .q(buffer_finished)
    );

    assign flip_read_index = flip_condition_pulsed & buffer_finished;

endmodule
