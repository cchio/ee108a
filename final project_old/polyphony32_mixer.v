`define DELAY 2'd2

module polyphony32_mixer (
    input clk,
    input reset,
    input [7:0] multiplier,
    input samples_ready,
    input [511:0] samples,
    output sample_ready,
    output [15:0] sample
);

    // Samples are added and then effectively divided
    wire signed [15:0] sample_array [31:0];

    assign {sample_array[31], sample_array[30], sample_array[29],
      sample_array[28], sample_array[27], sample_array[26], sample_array[25],
      sample_array[24], sample_array[23], sample_array[22], sample_array[21],
      sample_array[20], sample_array[19], sample_array[18], sample_array[17],
      sample_array[16], sample_array[15], sample_array[14], sample_array[13],
      sample_array[12], sample_array[11], sample_array[10], sample_array[9],
      sample_array[8], sample_array[7], sample_array[6], sample_array[5],
      sample_array[4], sample_array[3], sample_array[2], sample_array[1],
      sample_array[0]} = samples;

    wire signed [19:0] sum = sample_array[0] + sample_array[1]
      + sample_array[2] + sample_array[3] + sample_array[4] + sample_array[5]
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

    reg signed [15:0] mixed_output;
    reg sample_ready1;
    reg [1:0] state1;
    wire [1:0] state;

    dffr #(.WIDTH(2)) state_ff (
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

    dffr #(.WIDTH(16)) out (
        .clk(clk),
        .r(reset),
        .d(mixed_output),
        .q(sample)
    );

    always @(*) begin
        if (reset) begin
            mixed_output = 16'sb0;
            sample_ready1 = 1'b0;
            state1 = 2'b0;
        end
        else if (samples_ready & (state == 2'b0)) begin
            mixed_output = sum - (multiplier * (sum >> 8));
            state1 = state + 2'b1;
        end
        else if ((state != 2'b0) & (state != `DELAY)) state1 = state + 1'b1;
        else if (state == `DELAY) begin
            sample_ready1 = 1'b1;
            state1 = 2'b0;
        end
        else begin
            state1 = 2'b0;
            sample_ready1 = 1'b0;
            mixed_output = sample;
        end
    end

endmodule
