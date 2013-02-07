`timescale 1ns / 1ps

module timer_tb();
	reg clk_sim;
	reg rst_sim;
	reg [8:0] load_value_sim;
	reg count_en_sim;
	wire out_sim;

/*
module timer (
    input [8:0] load_value,
    input count_en,
    input clk,
    input reset,
    output reg timer_out
); 
*/


timer timing(.load_value(load_value_sim),
		.clk(clk_sim),
		.reset(rst_sim),
		.count_en(count_en_sim),
		.timer_out(out_sim) );

initial begin
	clk_sim = 0;

	//Generate clock	
	forever #1 clk_sim = ~clk_sim;
end

initial begin
	count_en_sim = 0;
	forever #2 count_en_sim = ~count_en_sim;
end

initial begin
        
	load_value_sim = 9'b0;
	rst_sim = 0;
	
	//Initial reset
	rst_sim = 1;
	#3
	rst_sim = 0;
	#3

	//countdown from 9'b000000100
	load_value_sim = 9'b000000100;
	#40;

	//countdown from 9'b000001000
	load_value_sim = 9'b000001000;
	#40;

	//countdown from 9'b000010000
	load_value_sim = 9'b000010000;
	#80;

	//countdown from 9'b000100000
	load_value_sim = 9'b000100000;
	#80;

	//countdown from 9'b001000000
	load_value_sim = 9'b001000000;
	#120;

	//countdown from 9'b010000000
	load_value_sim = 9'b010000000;
	#480;

	//countdown from 9'b100000000
	load_value_sim = 9'b100000000;
	#1500;
	
	//Reset
	rst_sim = 1;
	#10
	rst_sim = 0;


$finish;

end

endmodule
