`timescale 1ns / 1ps

module programmable_blinker_tb();
	reg clk_sim;
	reg rst_sim;
	reg [15:0] secs;
	reg sl_sim;
	reg sr_sim;
	reg fast_sim;
	wire out_sim;


programmable_blinker prog_blink(  .shift_left(sl_sim),
				.shift_right(sr_sim),
				.clk(clk_sim),
				.reset(rst_sim),
				.count_en(clk_sim),
				.fast(fast_sim),
				.programmable_blinker_out(out_sim)
);

initial begin
	clk_sim = 0;
#1;

	//Generate clock	
	forever #1 clk_sim = ~clk_sim;
end

initial begin
secs = 0;
	forever #8 secs = secs + 1;
end

initial begin
$monitor("secs %d, out %b", secs, out_sim);
	sl_sim = 0;
	sr_sim = 0;
	fast_sim = 0;

	//Initial reset
	rst_sim = 1;
	#32;
	rst_sim = 0;
	#288;

sr_sim = 1;
#2;
sr_sim = 0;
#512;
sr_sim = 1;
#2;
sr_sim = 0;
#1024;
sr_sim = 1;
#2;
sr_sim = 0;
#2048;
// test extra shift right
sr_sim = 1;
#2;
sr_sim = 0;
#2048;
// reset
rst_sim = 1;
#4;
rst_sim = 0;
#4;

// Fast test
fast_sim = 1;
#256;
sr_sim = 1;
#2;
sr_sim = 0;
#128;
sr_sim = 1;
#2;
sr_sim = 0;
#64;
sr_sim = 1;
#2;
sr_sim = 0;
#32;
// test extra shift left
sr_sim = 1;
#2;
sr_sim = 0;
#32;
// reset
rst_sim = 1;
#4;
rst_sim = 0;
#4;


$finish;

end

endmodule
