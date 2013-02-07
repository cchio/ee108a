`timescale 1ns/1ps
module float_add();

reg [7:0] aIn_sim;
reg [7:0] bIn_sim;
wire [7:0] result_sim;

float_add add(.aIn(aIn_sim), .bIn(bIn_sim), .result(result_sim));

initial begin

//Test with no overflows or shifts

	aIn_sim = 8'b00001000;
	bIn_sim = 8'b00000011;

	#10 //Pause 10 timesteps
	
	$display("Output was %b; %b was expected.",
		 result_sim, 8'b00001011);
	
	#10

//Test with no overflows, 1 shift, out of order
	aIn_sim = 8'b00001100;
	bIn_sim = 8'b00110001;

	#10 //Pause 10 timesteps
	
	$display("Output was %b; %b was expected.",
		 result_sim, 8'b00110111);
	
	#10

//Test with mantissa overflowed
	aIn_sim = 8'b10010010;
	bIn_sim = 8'b01011111;

	#10 //Pause 10 timesteps
	
	$display("Output was %b; %b was expected.",
		 result_sim, 8'b10011001);
	
	#10

//Test with exp overflowed
	aIn_sim = 8'b11110001;
	bIn_sim = 8'b11101100;

	#10 //Pause 10 timesteps
	
	$display("Output was %b; %b was expected.",
		 result_sim, 8'b11111111);
	
	#10

//Test with both overflowed and a shift
	aIn_sim = 8'b11111111;
	bIn_sim = 8'b11001100;

	#10 //Pause 10 timesteps
	
	$display("Output was %b; %b was expected.",
		 result_sim, 8'b11111111);
	
	#10

//Test with 0s
	aIn_sim = 8'b0;
	bIn_sim = 8'b0;

	#10 //Pause 10 timesteps
	
	$display("Output was %b; %b was expected.",
		 result_sim, 8'b00000000);
	
	#10