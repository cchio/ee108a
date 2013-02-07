`timescale 1ns/1ps
module adder_tb();
	reg [4:0] sim_a,sim_b;
	wire [2:0] sim_shift;
	wire sim_dir;
	wire [4:0] sim_sum;

	adder add(.a(sim_a), .b(sim_b), .shift(sim_shift)
		  .dir(sim_dir), .sum(sim_sum));

	initial begin
	
	//Several additions with no overflows

	sim_a = 5'b10000;
	sim_b = 5'b01111;

	#10 //Pause 10 time steps

	$display("Shift is %b, dir is %b, and sum is %b;\n
		 %b, %b, and %b were expected.", sim_shift,\n 
		sim_dir, sim_sum, 3'b000, 1'b0, 5'b11111);

	#10

	sim_a = 5'b01111;
	sim_b = 5'b10000;

	#10 //Pause 10 time steps

	$display("Shift is %b, dir is %b, and sum is %b;\n
		 %b, %b, and %b were expected.", sim_shift,\n 
		sim_dir, sim_sum, 3'b000, 1'b0, 5'b11111);

	#10

	sim_a = 5'b01010;
	sim_b = 5'b00100;

	#10 //Pause 10 time steps

	$display("Shift is %b, dir is %b, and sum is %b;\n
		 %b, %b, and %b were expected.", sim_shift,\n 
		sim_dir, sim_sum, 3'b001, 1'b0, 5'b01110);

	#10

	sim_a = 5'b00001;
	sim_b = 5'b00010;

	#10 //Pause 10 time steps

	$display("Shift is %b, dir is %b, and sum is %b;\n
		 %b, %b, and %b were expected.", sim_shift,\n 
		sim_dir, sim_sum, 3'b011, 1'b0, 5'b00011);

	#10

//Test a couple of overflow cases

	sim_a = 5'b11101;
	sim_b = 5'b10000;

	#10 //Pause 10 time steps

	$display("Shift is %b, dir is %b, and sum is %b;\n
		 %b, %b, and %b were expected.", sim_shift,\n 
		sim_dir, sim_sum, 3'b000, 1'b1, 5'b10110);

	#10

	sim_a = 5'b11111;
	sim_b = 5'b00001;

	#10 //Pause 10 time steps

	$display("Shift is %b, dir is %b, and sum is %b;\n
		 %b, %b, and %b were expected.", sim_shift,\n 
		sim_dir, sim_sum, 3'b000, 1'b1, 5'b00000);

	#10

	$stop
end
endmodule