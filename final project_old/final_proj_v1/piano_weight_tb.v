`timescale 1ns / 1ps

module piano_weight_tb();

reg clk_sim;
reg rst_sim;
reg signed [15:0] s1_sim;
reg signed [15:0] s2_sim;
reg signed [15:0] s3_sim;
reg signed [15:0] s4_sim;
reg signed [15:0] s5_sim;
reg signed [15:0] s6_sim;
reg signed [15:0] s7_sim;
reg signed [15:0] s8_sim;

wire signed [15:0] samp_sim;

piano_weight w(.s1(s1_sim), .s2(s2_sim), .s3(s3_sim), .s4(s4_sim), .s5(s5_sim), .s6(s6_sim), .s7(s7_sim), .s8(s8_sim), .sample(samp_sim));

initial begin
	clk_sim = 1'b0;
	forever #2 clk_sim = ~clk_sim;

	//Reset
	rst_sim = 1'b1;
	#4;
	rst_sim = 1'b0;
	#4;
end

initial begin
	#20
	s1_sim = 16'b1010101010101010;
	s2_sim = 16'b0011101010101010;
	s3_sim = 16'b1010001101101010;
	s4_sim = 16'b1001111011001110;
	s5_sim = 16'b1111111010101010;
	s6_sim = 16'b0000000000000010;
	s7_sim = 16'b1010111101000100;
	s8_sim = 16'b1011000001001010;
	
	#6

	s1_sim = 16'b0010101010101010;
	s2_sim = 16'b0011101010101010;
	s3_sim = 16'b1010001101101010;
	s4_sim = 16'b1001111011001110;
	s5_sim = 16'b1111111010101010;
	s6_sim = 16'b0000000000000010;
	s7_sim = 16'b1010111101000100;
	s8_sim = 16'b1011000001001010;
	
	#6
	$display("The correct answer is %b", s1_sim*5'd32 + s2_sim*5'd20 + s3_sim*5'd20 + s1_sim*5'd1 + s1_sim*5'd2 + s1_sim*5'd0 + s1_sim*5'd1 + s1_sim*5'd0);

	$finish;
	
end

endmodule
