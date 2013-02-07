`timescale 1ns/1ps
module RevPriEnc53_tb();
	reg [4:0] sim_a;
	wire [2:0] sim_b;

	RevPriEnc53 priEnc(.a(sim_a), .b(sim_b));

	initial begin

//Test for output with 1 in MSB
	sim_a = 5'b11111;

	#10
	
	$display("Output is %b, we expected %b", sim_b, (3'b000));

	#10

//Test for output with 1 in 1 after MSB
	sim_a = 5'b01100;

	#10
	
	$display("Output is %b, we expected %b", sim_b, (3'b001));

	#10

//Test for output with 1 in 2 after MSB
	sim_a = 5'b00101;

	#10
	
	$display("Output is %b, we expected %b", sim_b, (3'b010));

	#10

//Test for output with 1 in 3 after MSB
	sim_a = 5'b00011;

	#10
	
	$display("Output is %b, we expected %b", sim_b, (3'b011));

	#10

//Test for output with 1 in LSB
	sim_a = 5'b00001;

	#10
	
	$display("Output is %b, we expected %b", sim_b, (3'b100));

	#10

//Test for output with no 1s
	sim_a = 5'b00000;

	#10
	
	$display("Output is %b, we expected %b", sim_b, (3'b000));

	$stop
end
endmodule