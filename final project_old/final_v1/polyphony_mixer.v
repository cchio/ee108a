`include "num_notes.v"
`define MIXER_DELAY 3'd7

module polyphony_mixer (
    input clk,
    input reset,
    input [7:0] multiplier,
    input samples_ready,
    input [`NUM_NOTES*16-1:0] samples,
    output sample_ready,
    output signed [15:0] sample
);

    // Samples are added and then scaled based on the number of notes playing
    wire signed [15:0] sample_array [`NUM_NOTES-1:0];

    assign {sample_array[3], sample_array[2], sample_array[1],
      sample_array[0]} = samples;

    wire signed [19:0] sum1 = sample_array[0] + sample_array[1]
      + sample_array[2] + sample_array[3];
/*      + sample_array[4] + sample_array[5]
      + sample_array[6] + sample_array[7] + sample_array[8]
      + sample_array[9] + sample_array[10] + sample_array[11]
      + sample_array[12] + sample_array[13]
      + sample_array[14] + sample_array[15] + sample_array[16]
      + sample_array[17] + sample_array[18]
      + sample_array[19] + sample_array[20] + sample_array[21]
      + sample_array[22] + sample_array[23]
      + sample_array[24] + sample_array[25] + sample_array[26]
      + sample_array[27] + sample_array[28]
      + sample_array[29] + sample_array[30] + sample_array[31];
*/

    wire signed [27:0] product, result;
    reg sample_ready1;
    reg [2:0] state1;
    wire [2:0] state;
    wire signed [19:0] sum, shift;
    wire [7:0] mult;


    // assigns
    assign sample = result[15:0];


    dffr #(.WIDTH(3)) state_ff (
        .clk(clk),
        .r(reset),
        .d(state1),
        .q(state)
    );

    dffr ready (
        .clk(clk),
        .r(reset),
        .d(sample_ready1),
        .q(sample_ready)
    );

    dffr #(.WIDTH(20)) sample_sum (
        .clk(clk),
        .r(reset),
        .d(sum1),
        .q(sum)
    );

    dffr #(.WIDTH(8)) mult_ff (
        .clk(clk),
        .r(reset),
        .d(multiplier),
        .q(mult)
    );

    dffr #(.WIDTH(20)) shift_ff (
        .clk(clk),
        .r(reset),
        .d(sum >>> 8),
        .q(shift)
    );

    dffr #(.WIDTH(28)) product_ff (
        .clk(clk),
        .r(reset),
        .d(mult*shift),
        .q(product)
    );

    dffr #(.WIDTH(28)) result_ff (
        .clk(clk),
        .r(reset),
        .d(sum - product),
        .q(result)
    );


    always @(*) begin
        if (reset) begin
            sample_ready1 = 1'b0;
            state1 = 3'b0;
        end
        else if (samples_ready & (state == 3'b0))
            state1 = state + 3'b1;
        else if ((state != 3'b0) & (state != `MIXER_DELAY)) state1 = state + 3'b1;
        else if (state == `MIXER_DELAY) begin
            sample_ready1 = 1'b1;
            state1 = 3'b0;
        end
        else begin
            state1 = state;
            sample_ready1 = 1'b0;
        end
    end

endmodule
