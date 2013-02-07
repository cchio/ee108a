`timescale 1ns / 1ps

module blinker_tb();
	reg clk_sim;
	reg bs_sim;
	reg rst_sim;
	wire out_sim;

blinker blink(  .blinker_switch(bs_sim),
		.clk(clk_sim),
		.reset(rst_sim),
		.blinker_out(out_sim) );

initial begin
	clk_sim = 0;

	//Generate clock	
	forever #1 clk_sim = ~clk_sim;
end

initial begin

	bs_sim = 0;
	rst_sim = 0;


	//Initial reset
	rst_sim = 1;
	#3
	rst_sim = 0;
	#3

	//blinker set to 1
	bs_sim = 1;
	#2;

	//blinker set to 0
	bs_sim = 0;
	#2

	//blinker set to 1
	bs_sim = 1;
	#2;

	//blinker set to 0
	bs_sim = 0;
	#2

	//blinker set to 1
	bs_sim = 1;
	#2;

	//blinker set to 0
	bs_sim = 0;
	#2

	//blinker set to 1
	bs_sim = 1;
	#2;

	//blinker set to 0
	bs_sim = 0;
	#2
	
	//Reset
	rst_sim = 1;
	#10
	rst_sim = 0;

$finish;

end

endmodule
