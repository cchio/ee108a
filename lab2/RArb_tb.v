`timescale 1ns/1ps
module RArb_tb();
	reg [4:0] sim_r;
	wire [4:0] sim_g;

	RArb arb(.r(sim_r), .g(sim_g));

	initial begin

//Test for output with 1 in MSB
	sim_r = 5'b11111;

	#10
	
	$display("Output is %b, we expected %b", sim_g, (5'b10000));

	#10

//Test for output with 1 in 1 after MSB
	sim_r = 5'b01100;

	#10
	
	$display("Output is %b, we expected %b", sim_g, (5'b01000));

	#10

//Test for output with 1 in 2 after MSB
	sim_r = 5'b00101;

	#10
	
	$display("Output is %b, we expected %b", sim_g, (5'b00100));

	#10

//Test for output with 1 in 3 after MSB
	sim_r = 5'b00011;

	#10
	
	$display("Output is %b, we expected %b", sim_g, (5'b00010));

	#10

//Test for output with 1 in LSB
	sim_r = 5'b00001;

	#10
	
	$display("Output is %b, we expected %b", sim_g, (5'b00001));

	#10

//Test for output with no 1s
	sim_r = 5'b00000;

	#10
	
	$display("Output is %b, we expected %b", sim_g, (5'b00000));

	$stop
end
endmodule