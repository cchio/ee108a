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
$monitor("fast %b, rst %b, sl %b, sr %b, out %b", fast_sim, rst_sim, sl_sim, sr_sim, out_sim);
	sl_sim = 0;
	sr_sim = 0;
	fast_sim = 0;
// initial reset
	rst_sim = 1;
	#10;
	rst_sim = 0;
	#10;
//Slow flash (fast = 0)
// currently in one second state
#10;
repeat(4) begin
sr_sim = 1;
#2;
sr_sim = 0;
#10;
end

// Move the other direction
repeat(4) begin
sl_sim = 1;
#2;
sl_sim = 0;
#10;
end

// Reset and try fast setting
rst_sim = 1;
#10;
rst_sim = 0;
#10;

fast_sim = 1;
#10;

// shift right
repeat(4) begin
sr_sim = 1;
#2;
sr_sim = 0;
#10;
end

// Shift th other way
repeat(4) begin
sl_sim = 1;
#2;
sl_sim = 0;
#10;
end

$finish;

end

endmodule
