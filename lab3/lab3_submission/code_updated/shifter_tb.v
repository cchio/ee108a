`timescale 1ns / 1ps

module shifter_tb();
	reg clk_sim;
	reg sl_sim;
	reg sr_sim;
	reg fast_sim;
	reg rst_sim;
	wire [6:0] out_sim;

shifter shift(  .shift_left(sl_sim),
		.shift_right(sr_sim),
		.fast(fast_sim),
		.clk(clk_sim),
		.reset(rst_sim),
		.out(out_sim));

initial begin
	clk_sim = 0;

	//Generate clock	
	forever #1 clk_sim = ~clk_sim;
end


initial begin
	
	sl_sim = 0;
	sr_sim = 0;
	fast_sim = 0;
	rst_sim = 0;

	//Initial reset
	rst_sim = 1;
	#3
	rst_sim = 0;
	#4

//Slow flash (fast = 0)
	//To second state
	sr_sim = 1;
	#1
	sr_sim = 0;
	#9

	//To third
	sr_sim = 1;
	#1
	sr_sim = 0;
	#9

	//To fourth
	sr_sim = 1;
	#1
	sr_sim = 0;
	#9

	//Try to go past fourth
	sr_sim = 1;
	#1
	sr_sim = 0;
	#9

	//Down to third
	sl_sim = 1;
	#1
	sl_sim = 0;
	#9

	//Down to second
	sl_sim = 1;
	#1
	sl_sim = 0;
	#9

	//Down to first
	sl_sim = 1;
	#1
	sl_sim = 0;
	#9

	//Try to pass first
	sl_sim = 1;
	#1
	sl_sim = 0;
	#9

	//Reset, switch to fast
	rst_sim = 1;
	fast_sim = 1;	
	#10
	rst_sim = 0;
	#10;

//Fast flash (fast = 1)
	//To second state
	sr_sim = 1;
	#1
	sr_sim = 0;
	#9

	//To third
	sr_sim = 1;
	#1
	sr_sim = 0;
	#9

	//To fourth
	sr_sim = 1;
	#1
	sr_sim = 0;
	#9

	//Try to go past fourth
	sr_sim = 1;
	#1
	sr_sim = 0;
	#9

	//Down to third
	sl_sim = 1;
	#1
	sl_sim = 0;
	#9

	//Down to second
	sl_sim = 1;
	#1
	sl_sim = 0;
	#9

	//Down to first
	sl_sim = 1;
	#1
	sl_sim = 0;
	#9

	//Try to pass first
	sl_sim = 1;
	#1
	sl_sim = 0;
	#9

	//Reset
	rst_sim = 1;
	fast_sim = 1;	
	#10
	rst_sim = 0;
	#10;

$finish;

end

endmodule
