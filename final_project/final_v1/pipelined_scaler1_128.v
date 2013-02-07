// This module is a pipelined scaler
// The input is dived by 128 and multiplied by the supplied "multiplier"
// The operation takes 6 clock cycles to appear on the output

module pipelined_scaler1_128 (
    input clk,
    input reset,
    input [7:0] multiplier,
    input signed [15:0] in,
    output signed [15:0] out
);

    wire [7:0] mult1, mult;
    wire signed [15:0] sample_in_ff1, sample_in_ff, result1, result;
    wire [15:0] usample_ff1, usample_ff, uresult1, uresult;
    wire [22:0] shift1, shift;
    wire [29:0] product1, product;

    // pipelined scaling operation
    assign sample_in_ff1 = in;
    assign mult1 = multiplier;
    assign usample_ff1 = (sample_in_ff[15])
      ? ~(sample_in_ff-16'b1)
      : sample_in_ff;
    assign shift1 = {usample_ff, 7'b0}>>7;
    assign product1 = {mult, 7'b0}*shift;
    assign uresult1 = product[29:14];
    assign result1 = (sample_in_ff[15])
      ? (~(uresult))+16'b1
      : uresult;
    assign out = result;


    // flip flops

    dffr #(.WIDTH(16)) sample_in (
        .clk(clk),
        .r(reset),
        .d(sample_in_ff1),
        .q(sample_in_ff)
    );


    dffr #(.WIDTH(8)) scaler (
        .clk(clk),
        .r(reset),
        .d(mult1),
        .q(mult)
    );


    dffr #(.WIDTH(16)) usample (
        .clk(clk),
        .r(reset),
        .d(usample_ff1),
        .q(usample_ff)
    );


    dffr #(.WIDTH(23)) shifted_val (
        .clk(clk),
        .r(reset),
        .d(shift1),
        .q(shift)
    );


    dffr #(.WIDTH(30)) product_ff (
        .clk(clk),
        .r(reset),
        .d(product1),
        .q(product)
    );


    dffr #(.WIDTH(16)) uresult_ff (
        .clk(clk),
        .r(reset),
        .d(uresult1),
        .q(uresult)
    );


    dffr #(.WIDTH(16)) result_ff (
        .clk(clk),
        .r(reset),
        .d(result1),
        .q(result)
    );

endmodule
