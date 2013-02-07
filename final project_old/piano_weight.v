module piano_weight( input wire signed [15:0] s1,
		     input wire signed [15:0] s2,	
		     input wire signed [15:0] s3,
		     input wire signed [15:0] s4,
		     input wire signed [15:0] s5,
       		     input wire signed [15:0] s6,
		     input wire signed [15:0] s7,
		     input wire signed [15:0] s8,
		     output wire signed [15:0] sample);
					 
wire signed [23:0] t1;
wire signed [23:0] t2;
wire signed [23:0] t3;
wire signed [23:0] t4;
wire signed [23:0] t5;
wire signed [23:0] t6;
wire signed [23:0] t7;
wire signed [23:0] t8;

assign t1 = {s1, 8'd0};
assign t2 = {s2, 8'd0};
assign t3 = {s3, 8'd0};
assign t4 = {s4, 8'd0};
assign t5 = {s5, 8'd0};
assign t6 = {s6, 8'd0};
assign t7 = {s7, 8'd0};
assign t8 = {s8, 8'd0};

/*wire signed [23:0] sum1;
wire signed [23:0] sum2;
wire signed [23:0] sum3;
wire signed [23:0] sum;

assign sum1 = (t1 >>> 3) + ( (t2 >>> 4) + (t2 >>> 6) );
assign sum2 = ( (t3 >>> 4) + (t3 >>> 6) ) + (t4 >>> 8);
assign sum3 = (t5 >>> 7) + (t7 >>> 8);
assign sum = sum1 + sum2 + sum3;*/

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
wire signed [23:0] w7;

assign w1 = t1 >>> 3;
assign w2 = (t2 >>> 4) + (t2 >>> 6);
assign w3 = (t3 >>> 4) + (t3 >>> 6);
assign w4 = t4 >>> 8;
assign w5 = t5 >>> 7;
assign w7 = t7 >>> 8;

assign sum1 = w1 + w2;
assign sum2 = w3 + w4;
assign sum3 = w5 + w7;
assign sum = sum1 + sum2 + sum3;

//This might not be right; it doesn't consider the sign bit, instead assuming the [22] to be the same.
assign sample = sum[22:7];

endmodule
