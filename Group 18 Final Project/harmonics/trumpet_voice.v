
module trumpet_voice 
		(input clk,
		 input reset,
         	 input load_new_note,
		 input generate_next,
		 input [19:0] freq,
        	 input [5:0] note_in,
		 input done,
		 output sample_out_ready,
		 output [15:0] sample);

wire ready;
wire signed [15:0] samp1;
wire signed [15:0] samp2;
wire signed [15:0] samp3;
wire signed [15:0] samp4;
wire signed [15:0] samp5;
wire signed [15:0] samp6;
wire signed [15:0] samp7;
wire signed [15:0] samp8;

//Create the step sizes of the different harmonics
wire [22:0] s1;
wire [22:0] s2;
wire [22:0] s3;
wire [22:0] s4_in;
wire [22:0] s4_out;
wire [22:0] s5;
wire [22:0] s6;
wire [22:0] s7;
wire [22:0] s8;

assign s1 = {3'b0,freq};
assign s2 = s1 << 1;
assign s3 = s2 + s1;
assign s4_in = s3 + s1;

dffr #(23) ff(.clk(clk), .r(reset), .d(s4_in), .q(s4_out));

assign s5 = s4_out + s1;
assign s6 = s5 + s1;
assign s7 = s6 + s1;
assign s8 = s7 + s1;

//Circumvent imprecision due to overflow
wire [19:0] step1;
wire [19:0] step2;
wire [19:0] step3;
wire [19:0] step4;
wire [19:0] step5;
wire [19:0] step6;
wire [19:0] step7;
wire [19:0] step8;

assign step1 = freq;
assign step2 = (s2[22:20] == 3'b0) ? s2[19:0] : 20'b0;
assign step3 = (s3[22:20] == 3'b0) ? s3[19:0] : 20'b0;
assign step4 = (s4_out[22:20] == 3'b0) ? s4_out[19:0] : 20'b0;
assign step5 = (s5[22:20] == 3'b0) ? s5[19:0] : 20'b0;
assign step6 = (s6[22:20] == 3'b0) ? s6[19:0] : 20'b0;
assign step7 = (s7[22:20] == 3'b0) ? s7[19:0] : 20'b0;
assign step8 = (s8[22:20] == 3'b0) ? s8[19:0] : 20'b0;

//Create the harmonics
sine_reader2 sin1(
        .clk(clk),
        .reset(reset),
        .step_size(step1),
        .generate_next(generate_next),
	.done(done),
        .sample_ready(),
        .sample(samp1)
    );

sine_reader2 sin2(
        .clk(clk),
        .reset(reset),
        .step_size(step2),
        .generate_next(generate_next),
	.done(done),
        .sample_ready(),
        .sample(samp2)
    );

sine_reader2 sin3(
        .clk(clk),
        .reset(reset),
        .step_size(step3),
        .generate_next(generate_next),
	.done(done),
        .sample_ready(),
        .sample(samp3)
    );

sine_reader2 sin4(
        .clk(clk),
        .reset(reset),
        .step_size(step4),
        .generate_next(generate_next),
	.done(done),
        .sample_ready(),
        .sample(samp4)
    );

sine_reader2 sin5(
        .clk(clk),
        .reset(reset),
        .step_size(step5),
        .generate_next(generate_next),
	.done(done),
        .sample_ready(),
        .sample(samp5)
    );

sine_reader2 sin6(
        .clk(clk),
        .reset(reset),
        .step_size(step6),
        .generate_next(generate_next),
	.done(done),
        .sample_ready(),
        .sample(samp6)
    );

sine_reader2 sin7(
        .clk(clk),
        .reset(reset),
        .step_size(step7),
        .generate_next(generate_next),
	.done(done),
        .sample_ready(),
        .sample(samp7)
    );

sine_reader2 sin8(
        .clk(clk),
        .reset(reset),
        .step_size(step8),
        .generate_next(generate_next),
	.done(done),
        .sample_ready(ready),
        .sample(samp8)
    );

wire signed [15:0] sample1;
wire signed [15:0] sample2;
wire signed [15:0] sample3;
wire signed [15:0] sample4;
wire signed [15:0] sample5;
wire signed [15:0] sample6;
wire signed [15:0] sample7;
wire signed [15:0] sample8;
wire samples_out_ready;
wire sample_ready;

dynamics #(5, 1000, 150,
	   5, 1000, 150,
	   5, 1000, 150,
	   5, 1000, 150,
	   5, 1000, 150,
	   5, 1000, 150,
	   5, 1000, 150,
	   5, 1000, 150)
 music_dynamics (
    .clk(clk),
    .reset(reset),
    .generate_next(generate_next),
    .load_new_note(load_new_note),
    .done(done),
    .samples_in_ready(ready),
    .sample_in1(samp1),
    .sample_in2(samp2),
    .sample_in3(samp3),
    .sample_in4(samp4),
    .sample_in5(samp5),
    .sample_in6(samp6),
    .sample_in7(samp7),
    .sample_in8(samp8),

    .samples_out_ready(samples_out_ready),
    .sample_out1(sample1),
    .sample_out2(sample2),
    .sample_out3(sample3),
    .sample_out4(sample4),
    .sample_out5(sample5),
    .sample_out6(sample6),
    .sample_out7(sample7),
    .sample_out8(sample8)
);


//Weight the samples

	//Expand samples by 8 bits
	//Multiply by weights and add,
	//then divide by 128
trumpet_weight weights(
	      .clk(clk),
	      .reset(reset),
	      .ready(samples_out_ready),
	      .s1(sample1),
	      .s2(sample2),
	      .s3(sample3),
	      .s4(sample4),
	      .s5(sample5),
	      .s6(sample6),
	      .s7(sample7),
	      .s8(sample8),
	      .sample_ready(sample_ready),
	      .sample(sample));

wire sample_rdy1;

//Delay the ready output by one cycle to match the samples (pipelined in piano_weight)
dffr samp_rdy_ff(.clk(clk), .r(reset), .d(sample_ready), .q(sample_rdy1));
//dffr samp_rdy_ff(.clk(clk), .r(reset), .d(ready), .q(sample_rdy1));
dffr samp_rdy_ff2(.clk(clk), .r(reset), .d(sample_rdy1), .q(sample_out_ready));

endmodule
