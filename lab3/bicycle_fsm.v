// Bicycle Light FSM
//
// This module determines how the light functions in the given state and what
// the next state is for the given state.
// 
// It is a structural module: it just instantiates other modules and hooks
// up the wires between them correctly.

/* For this lab, you need to implement the finite state machine following the
 * specifications in the lab hand-out */

module bicycle_fsm(
    input clk, 
    input up_button, 
    input down_button, 
    input next, 
    input reset, 
    output wire rear_light
);

    /* This Master FSM instantiation follows the diagram in the lab handout 
     * exactly, giving names to the unnamed signals between modules. */

    wire left1, right1, left2, right2;
    wire [1:0] mux_sel;

    master_fsm fsm (
        .clk(clk),
        .reset(reset),
        .up_button(up_button),
        .down_button(down_button),
        .next(next),
        .left1(left1),    // Should go to shift_left of programmable_blinker 1
        .right1(right1),  // Should go to shift_right of programmable_blinker 1
        .left2(left2),    // Should go to shift_left of programmable_blinker 2
        .right2(right2),  // Should go to shift_right of programmable_blinker 2
        .mux_sel(mux_sel)
    );

    /* Declare the rest of the wires between the modules, and instantiate them
     * below as we instantiated the Master FSM above. */
    wire heartBeat;
    wire blinkerOut1, blinkerOut2;
    reg mux_output;

    // Instantiation of beat32 to produce the 1/32 sec heartbeat
    beat32 hbeat(
        .clk(clk),
        .reset(reset),
        .count_en(heartBeat)
    );

    // Instantiation of the slowBlinker and fastBlinker modules
    programmable_blinker slowBlink(
        .clk(clk),
        .reset(reset),
        .shift_left(left1),
        .shift_right(right1),
	.count_en(heartBeat),
        .programmable_blinker_out(blinkerOut1),
	.fast(1'b0)
    );

    programmable_blinker fastBlink(
        .clk(clk),
        .reset(reset),
        .shift_left(left2),
        .shift_right(right2),
	.count_en(heartBeat),
        .programmable_blinker_out(blinkerOut2),
	.fast(1'b1)
    );

    // This block is the output mix which selects the signal to forward to the light
    always @(*) begin
        case (mux_sel)
          2'b00: mux_output = 1'b0;
          2'b01: mux_output = 1'b1;
          2'b10: mux_output = blinkerOut1;
          2'b11: mux_output = blinkerOut2;
          default: mux_output = 1'b0;
        endcase
    end

    assign rear_light = mux_output;

endmodule
