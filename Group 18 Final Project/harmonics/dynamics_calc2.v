`define CYCLES 4'd8

module dynamics_calc2 (
    input clk,
    input reset,
    input samples_in_ready,
    input [7:0] velocity,

    input signed [15:0] sample_in1,
    input [7:0] gain1,
    input decay_type1,

    input signed [15:0] sample_in2,
    input [7:0] gain2,
    input decay_type2,

    input signed [15:0] sample_in3,
    input [7:0] gain3,
    input decay_type3,

    input signed [15:0] sample_in4,
    input [7:0] gain4,
    input decay_type4,

    input signed [15:0] sample_in5,
    input [7:0] gain5,
    input decay_type5,

    input signed [15:0] sample_in6,
    input [7:0] gain6,
    input decay_type6,

    input signed [15:0] sample_in7,
    input [7:0] gain7,
    input decay_type7,

    input signed [15:0] sample_in8,
    input [7:0] gain8,
    input decay_type8,

    output samples_out_ready,
    output signed [15:0] sample_out1,
    output signed [15:0] sample_out2,
    output signed [15:0] sample_out3,
    output signed [15:0] sample_out4,
    output signed [15:0] sample_out5,
    output signed [15:0] sample_out6,
    output signed [15:0] sample_out7,
    output signed [15:0] sample_out8
);

    wire signed [15:0] sample_in_array [7:0];
    wire [7:0] gain_array [7:0];
    wire [7:0] decay_array;
    reg signed [15:0] sample_out_array [7:0];
    reg [3:0] next_state, next_sub_state;
    wire [3:0] curr_state, curr_sub_state;
    wire [3:0] count;
    wire [7:0] mult1;
    wire [7:0] mult;
    wire signed [15:0] scaler_input1;
    wire signed [15:0] scaler_input;
    wire signed [15:0] scaler_output;
    wire samples_out_ready1;


    // assigns
    assign {sample_in_array[7], sample_in_array[6], sample_in_array[5],
      sample_in_array[4], sample_in_array[3], sample_in_array[2],
      sample_in_array[1], sample_in_array[0]} = {sample_in8, sample_in7,
      sample_in6, sample_in5, sample_in4, sample_in3, sample_in2, sample_in1};
    assign {gain_array[7], gain_array[6], gain_array[5], gain_array[4], gain_array[3],
      gain_array[2], gain_array[1], gain_array[0]} = {gain8, gain7, gain6, gain5,
      gain4, gain3, gain2, gain1};
    assign decay_array = {decay_type8, decay_type7, decay_type6, decay_type5,
      decay_type4, decay_type3, decay_type2, decay_type1};
    assign samples_out_ready1 = (count == `CYCLES) && (curr_state == 4'd4) &&
      (curr_sub_state == 4'd7);
    assign mult1 = ((curr_state == 4'b0) || (count != 4'b0))
      ? mult
      : (curr_state == 4'd1)
        ? gain_array[curr_sub_state]
        : (curr_state != 4'd4)
          ? decay_array[curr_sub_state] ? gain_array[curr_sub_state] : 8'd128
          : velocity + 8'b1;
    assign scaler_input1 = ((curr_state == 4'b0) || (count != 4'b0))
      ? scaler_input
      : (curr_state == 4'd1)
        ? sample_in_array[curr_sub_state]
        : scaler_output;


    // flip flop instantiations

    dffr samples_out_ready_ff (
        .clk(clk),
        .r(reset),
        .d(samples_out_ready1),
        .q(samples_out_ready)
    );

    dffr #(.WIDTH(4)) state1 (
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(curr_state)
    );

    dffr #(.WIDTH(4)) sub_state (
        .clk(clk),
        .r(reset),
        .d(next_sub_state),
        .q(curr_sub_state)
    );

    dffre #(.WIDTH(4)) counter (
        .clk(clk),
        .r(reset),
        .en(curr_state != 4'b0),
        .d((count == `CYCLES) ? 4'b0 : count + 4'b1),
        .q(count)
    );

    dffr #(.WIDTH(8)) multiplier (
        .clk(clk),
        .r(reset),
        .d(mult1),
        .q(mult)
    );

    dffr #(.WIDTH(16)) sample_out1_ff (
        .clk(clk),
        .r(reset),
        .d(sample_out_array[0]),
        .q(sample_out1)
    );

    dffr #(.WIDTH(16)) sample_out2_ff (
        .clk(clk),
        .r(reset),
        .d(sample_out_array[1]),
        .q(sample_out2)
    );

    dffr #(.WIDTH(16)) sample_out3_ff (
        .clk(clk),
        .r(reset),
        .d(sample_out_array[2]),
        .q(sample_out3)
    );

    dffr #(.WIDTH(16)) sample_out4_ff (
        .clk(clk),
        .r(reset),
        .d(sample_out_array[3]),
        .q(sample_out4)
    );

    dffr #(.WIDTH(16)) sample_out5_ff (
        .clk(clk),
        .r(reset),
        .d(sample_out_array[4]),
        .q(sample_out5)
    );

    dffr #(.WIDTH(16)) sample_out6_ff (
        .clk(clk),
        .r(reset),
        .d(sample_out_array[5]),
        .q(sample_out6)
    );

    dffr #(.WIDTH(16)) sample_out7_ff (
        .clk(clk),
        .r(reset),
        .d(sample_out_array[6]),
        .q(sample_out7)
    );

    dffr #(.WIDTH(16)) sample_out8_ff (
        .clk(clk),
        .r(reset),
        .d(sample_out_array[7]),
        .q(sample_out8)
    );

    dffr #(.WIDTH(16)) scaler_in (
        .clk(clk),
        .r(reset),
        .d(scaler_input1),
        .q(scaler_input)
    );


    // Pipelined multiplier for calculations

    pipelined_scaler1_128 scaler (
        .clk(clk),
        .reset(reset),
        .multiplier(mult),
        .in(scaler_input),
        .out(scaler_output)
    );


    // This block handles pipelining the multiplication operations
    always @(*) begin
        if (reset) begin
            next_state = 4'b0;
            next_sub_state = 4'b0;
            sample_out_array[0] = 16'b0;
            sample_out_array[1] = 16'b0;
            sample_out_array[2] = 16'b0;
            sample_out_array[3] = 16'b0;
            sample_out_array[4] = 16'b0;
            sample_out_array[5] = 16'b0;
            sample_out_array[6] = 16'b0;
            sample_out_array[7] = 16'b0;
        end
        else if (curr_state == 4'b0) begin
            next_sub_state = 4'b0;

            if (samples_in_ready) next_state = 4'b1;
        end
        else begin
            if (curr_state == 4'd1) begin
                if (count == `CYCLES)
                    next_state = curr_state + 4'b1;
                else begin
                    next_state = curr_state;
                    next_sub_state = curr_sub_state;
                end
            end
            else if (curr_state != 4'd4) begin
                if (count == `CYCLES)
                    next_state = curr_state + 4'b1;
                else begin
                    next_state = curr_state;
                    next_sub_state = curr_sub_state;
                end
            end
            else begin
                if (count == `CYCLES) begin
                    sample_out_array[curr_sub_state] = scaler_output;
                    if (curr_sub_state == 4'd7) begin
                        next_state = 4'b0;
                        next_sub_state = 4'b0;
                    end
                    else begin
                        next_state = 4'b1;
                        next_sub_state = curr_sub_state + 4'b1;
                    end
                end
                else
                    next_state = curr_state;
            end
        end
    end

endmodule
