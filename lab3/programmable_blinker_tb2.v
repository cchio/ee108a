`timescale 1ns / 1ps

module programmable_blinker_tb();
	reg clk_sim;
	reg rst_sim;
	reg count_en_sim;
	reg sl_sim;
	reg sr_sim;
	reg fast_sim;
	wire out_sim;

programmable_blinker prog_blink(  .shift_left(sl_sim),
				.shift_right(sr_sim),
				.clk(clk_sim),
				.reset(rst_sim),
				.count_en(count_en_sim),
				.fast(fast_sim),
				.programmable_blinker_out(out_sim) );

initial begin
	clk_sim = 0;

	//Generate clock	
	forever #1 clk_sim = ~clk_sim;
end

initial begin
	count_en_sim = 0;

	forever #8 count_en_sim = ~count_en_sim;
end

initial begin

	rst_sim = 0;
	sl_sim = 0;
	sr_sim = 0;
	fast_sim = 0;

	//Initial reset
	rst_sim = 1;
	#10
	rst_sim = 0;
	#10
	
	//Slow flash (fast = 0) and shift right
	sr_sim = 1;
	#1;
	sr_sim = 0;
	#10

#100

	sr_sim = 1;
	#1;
	sr_sim = 0;
	#9

#100

	sr_sim = 1;
	#1;
	sr_sim = 0;
	#9

	sr_sim = 1;
	#1;
	sr_sim = 0;
	#9
	
	//[TODO:] The rest of these buttons should be one-pulsed

	//Slow flash (fast = 0) and shift left
	sl_sim = 1;
	#1;
	sl_sim = 0;
	#9

	#100

	sl_sim = 1;
	#1;
	sl_sim = 0;
	#9

	#100

	sl_sim = 1;
	#1;
	sl_sim = 0;
	#9

	sl_sim = 1;
	#1;
	sl_sim = 0;
	#9

	//Reset
	rst_sim = 1;
	#10
	rst_sim = 0;

	//Fast flash (fast = 1) and shift right
	fast_sim = 1;

	sr_sim = 1;
	#1;
	sr_sim = 0;
	#9

	sr_sim = 1;
	#1;
	sr_sim = 0;
	#9

	sr_sim = 1;
	#1;
	sr_sim = 0;
	#9

	sr_sim = 1;
	#1;
	sr_sim = 0;
	#9
	
	
	//Fast flash (fast = 1) and shift left
	sl_sim = 1;
	#1;
	sl_sim = 0;
	#9

	sl_sim = 1;
	#1;
	sl_sim = 0;
	#9

	sl_sim = 1;
	#1;
	sl_sim = 0;
	#9

	sl_sim = 1;
	#1;
	sl_sim = 0;
	#9
	
	//Reset
	rst_sim = 1;
	#10
	rst_sim = 0;

$finish;

end

endmodule
