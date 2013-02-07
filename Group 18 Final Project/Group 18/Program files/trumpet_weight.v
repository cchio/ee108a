module trumpet_weight( 	input clk,
		     	input reset,
		    	input ready,
			input wire signed [15:0] s1,
			input wire signed [15:0] s2,	
			input wire signed [15:0] s3,
			input wire signed [15:0] s4,
			input wire signed [15:0] s5,
	       		input wire signed [15:0] s6,
			input wire signed [15:0] s7,
			input wire signed [15:0] s8,
			output sample_ready,
			output wire signed [15:0] sample);

wire signed [15:0] samp1;
wire signed [15:0] samp2;
wire signed [15:0] samp3;
wire signed [15:0] samp4;
wire signed [15:0] samp5;
wire signed [15:0] samp6;
wire signed [15:0] samp7;
wire signed [15:0] samp8;

//Pipelining
dffr #(16) ff_1(.clk(clk), .r(reset), .d(s1), .q(samp1));
dffr #(16) ff_2(.clk(clk), .r(reset), .d(s2), .q(samp2));
dffr #(16) ff_3(.clk(clk), .r(reset), .d(s3), .q(samp3));
dffr #(16) ff_4(.clk(clk), .r(reset), .d(s4), .q(samp4));
dffr #(16) ff_5(.clk(clk), .r(reset), .d(s5), .q(samp5));
dffr #(16) ff_6(.clk(clk), .r(reset), .d(s6), .q(samp6));
dffr #(16) ff_7(.clk(clk), .r(reset), .d(s7), .q(samp7));
dffr #(16) ff_8(.clk(clk), .r(reset), .d(s8), .q(samp8));

wire signed [23:0] t1;
wire signed [23:0] t2;
wire signed [23:0] t3;
wire signed [23:0] t4;
wire signed [23:0] t5;
wire signed [23:0] t6;
wire signed [23:0] t7;
wire signed [23:0] t8;

assign t1 = {samp1, 8'd0};
assign t2 = {samp2, 8'd0};
assign t3 = {samp3, 8'd0};
assign t4 = {samp4, 8'd0};
assign t5 = {samp5, 8'd0};
assign t6 = {samp6, 8'd0};
assign t7 = {samp7, 8'd0};
assign t8 = {samp8, 8'd0};

//Debug
wire signed [23:0] sum1;
wire signed [23:0] sum2;
wire signed [23:0] sum3;
wire signed [23:0] sum;
wire signed [23:0] w1;
wire signed [23:0] w2;
wire signed [23:0] w3;
wire signed [23:0] w4;
wire signed [23:0] w5;
wire signed [23:0] w6;

assign w1 = (t1 >>> 5) + (t1 >>> 6) + (t1 >>> 7); //t1*14
assign w2 = (t2 >>> 4) + (t2 >>> 5); //t1*24
assign w3 = t3 >>> 3; //t1*32
assign w4 = t4 >>> 4; //t1*16
assign w5 = t5 >>> 5; //t1*8
assign w6 = t7 >>> 6; //t1*4

assign sum1 = w1 + w2;
assign sum2 = w3 + w4;
assign sum3 = w5 + w6;
assign sum = sum1 + sum2 + sum3;

//Divide by 128
dffr #(16) div(.clk(clk), .r(reset), .d(sum[22:7]), .q(sample));

//Delay sample ready
dffr srdy(.clk(clk), .r(reset), .d(ready), .q(sample_ready));

/*
//This might not be right; it doesn't consider the sign bit, instead assuming the [22] to be the same.
assign sample = sum[22:7];*/

endmodule
