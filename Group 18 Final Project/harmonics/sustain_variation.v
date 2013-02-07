// This module calculates a variation in the number of audio samples of the
// sustain interval for the dynamics for each note
// This is done with a linear approximation to model a piano's variation

`define MAX_NOTE 6'd63
`define SUSTAIN_FACTOR 10'd50

module sustain_variation (
    input clk,
    input reset,
    input [5:0] note,
    output [15:0] count
);

    // calculate with a linear factor
    wire [5:0] note_ff;

    // flip flops

    dffr #(.WIDTH(6)) note_flipflop (
        .clk(clk),
        .r(reset),
        .d(`MAX_NOTE-note),
        .q(note_ff)
    );

    dffr #(.WIDTH(16)) count_ff (
        .clk(clk),
        .r(reset),
        .d(note_ff*`SUSTAIN_FACTOR),
        .q(count)
    );

endmodule
